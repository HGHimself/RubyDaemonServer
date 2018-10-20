require 'socket'
require "uri"
require "./CONFIG"
require 'fileutils'

class Request

  def initialize()
    @headers = Hash.new
    @body = ""
  end

  def method
    @method
  end

  def path
    @path
  end

  def header?(key)
    @headers[key]
  end

  def body
    @body
  end

  def bodySize
    @body.size
  end

  def addRequestLine(line)
    puts @requestLine = line.chomp
    @method = line.split(" ")[0]

    @path = requested_file(line)
    @path = File.join(path, 'index.html') if File.directory?(path)
  end

  def addHeader(header)
    arr = header.split(": ")
    key = arr[0]
    value = arr[1]
    @headers[key] = value
  end

  def addToBody(string)
    @body += string
  end

  def requested_file(request)
    uri = request.split(" ")[1]
    path = URI.unescape(URI(uri).path)

    clean = []

    parts = path.split("/")

    parts.each do |part|
      next if part.empty? || part == '.'
      part == '..' ? clean.pop : clean << part
    end

    File.join(WEB_ROOT, *clean)
  end

end

class Response
  def initialize(socket)
    @socket = socket
  end

  def send(path)
    begin
      if File.exist?(path) && !File.directory?(path)
        File.open(path, "rb") do |file|
          puts "We got a file! Returning -#{path}-"
          @socket.puts "HTTP/1.1 200 OK\r\n"
          @socket.puts "Content-Type: #{content_type(file)}\r\n"
          @socket.puts "Content-Length: #{file.size}\r\n"
          @socket.puts "Connection: close\r\n"
          IO.copy_stream(file, @socket)

        end
      else
        puts "We dont have a file..."
        error =  "File not found!\n"
        # respond with a 404 error code to indicate the file does not exist
        @socket.puts "HTTP/1.1 404 Not Found\r\n"
        @socket.puts "Content-Type: text/plain\r\n"
        @socket.puts "Content-Length: #{error.size}\r\n"
        @socket.puts "Connection: close\r\n"
        @socket.puts "\r\n"
        @socket.puts error
      end
    rescue
      puts "We have an error..."
      error = "There has been an internal server error!\n"
      # respond with a 404 error code to indicate the file does not exist
      @socket.puts "HTTP/1.1 500 Internal Server Error\r\n"
      @socket.puts "Content-Type: text/plain\r\n"
      @socket.puts "Content-Length: #{error.size}\r\n"
      @socket.puts "Connection: close\r\n"
      @socket.puts "\r\n"
      @socket.puts error
    end
  end

  def content_type(path)
    ext = File.extname(path).split(".").last
    CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
  end


end

class Server

  attr_reader :options, :quit

  def initialize(options)
    @options = options

    # daemonization will change CWD so expand relative paths now
    options[:logfile] = File.expand_path(logfile) if logfile?
    options[:pidfile] = File.expand_path(pidfile) if pidfile?
    #options[:logfile] = File.expand_path(LOG_FILE)
    #options[:pidfile] = File.expand_path(PID_FILE)
    options[:rootdir] = File.expand_path(WEB_ROOT)
    #if host? then options[:host] else HOST (from config file)
    @host = host? ? options[:host] : HOST
    @port = port? ? options[:port] : PORT
    @activeConnections = 0
    @server = TCPServer.new(@host, @port)
    puts "Listening at host: #{@host} on port: #{@port}"
  end

  def host?
    @options[:host]
  end

  def port?
    @options[:port]
  end


  def daemonize?
    options[:daemonize]
  end

  def logfile
    options[:logfile]
  end

  def pidfile
    options[:pidfile]
  end

  def rootdir
    options[:rootdir]
  end

  def logfile?
    !logfile.nil?
  end

  def pidfile?
    !pidfile.nil?
  end

  def run!
    puts "Starting run..."
    check_pid
    daemonize if daemonize?
    write_pid
    trap_signals

    if logfile?
      redirect_output
    elsif daemonize?
      suppress_output
    end

    puts "Starting server on #{Time.now}! Listening on HOST:#{HOST} at PORT:#{PORT}"
    while !quit
      self.listen
    end
    puts "Quit has been set to true"

  end

  def write_pid
    if pidfile?
      begin
        File.open(pidfile, ::File::CREAT | ::File::EXCL | ::File::WRONLY){|f| f.write("#{Process.pid}") }
        at_exit { File.delete(pidfile) if File.exists?(pidfile) }
      rescue Errno::EEXIST
        check_pid
        retry
      end
    end
  end

  def check_pid
    if pidfile?
      case pid_status(pidfile)
      when :running, :not_owned
        puts "A server is already running. Check #{pidfile}"
        exit(1)
      when :dead
        File.delete(pidfile)
      end
    end
  end

  def pid_status(pidfile)
    return :exited unless File.exists?(pidfile)
    pid = ::File.read(pidfile).to_i
    return :dead if pid == 0
    Process.kill(0, pid)      # check process status
    :running
  rescue Errno::ESRCH
    :dead
  rescue Errno::EPERM
    :not_owned
  end

  def daemonize
    exit if fork
    Process.setsid
    exit if fork
    Dir.chdir "/"
  end

  def redirect_output
    FileUtils.mkdir_p(File.dirname(logfile), :mode => 0755)
    FileUtils.touch logfile
    File.chmod(0644, logfile)
    $stderr.reopen(logfile, 'a')
    $stdout.reopen($stderr)
    $stdout.sync = $stderr.sync = true
  end

  def suppress_output
    $stderr.reopen('/dev/null', 'a')
    $stdout.reopen($stderr)
  end

  def trap_signals
    trap(:QUIT) do   # graceful shutdown of run! loop
      puts "Quit has been triggered!"
      @quit = true
    end
  end

  def listen
    loop do
      thread = Thread.start(@server.accept) do |socket|
        req = Request.new
        bodyFlag = 0
        breakFlag = 0
        line = socket.gets
        if line != nil
          req.addRequestLine(line.chomp)
          while breakFlag == 0 and line = socket.gets

            if bodyFlag == 0
              req.addHeader(line.chomp)
            else
              req.addToBody(line)
              if req.bodySize == req.header?("content-length").to_i
                breakFlag = 1
              end
            end

            if line == "\r\n"
              if req.method == "GET"
                breakFlag = 1
              else
                bodyFlag = 1
              end
            end

          end

          path = req.path
          res = Response.new(socket)
          res.send(path)
        end
        puts "Closing Socket and Ending Thread"
        socket.close
      end
      thread.join

    end
  end



end

options = {}
s = Server.new options
s.listen
