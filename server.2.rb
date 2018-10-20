require 'socket'
require "./CONFIG"
require "uri"
require 'fileutils'



module Emerald
  class Server

    attr_reader :options, :quit

    def initialize(options)
      #instance variables
      puts "Creating new server y'all!"
      @server = TCPServer.new(HOST, PORT)
      @options = options

      # daemonization will change CWD so expand relative paths now
      options[:logfile] = File.expand_path(logfile) if logfile?
      options[:pidfile] = File.expand_path(pidfile) if pidfile?
      #options[:logfile] = File.expand_path(LOG_FILE)
      #options[:pidfile] = File.expand_path(PID_FILE)
      options[:rootdir] = File.expand_path(WEB_ROOT)
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
      thread = Thread.start(@server.accept) do |socket|
        puts " "
        puts "**************"
        puts " "
        #puts "Incoming!! Starting a new thread."
        puts requestLine = socket.gets
        if requestLine != nil
          startTime = Time.now
          headers = Array.new
          begin
            requestLine = requestLine.chomp
            puts "Request line: #{requestLine}"
            #starting our response
            method = requestLine.split(" ")[1]

            path = requested_file(requestLine)
            path = File.join(path, 'index.html') if File.directory?(path)

            if File.exist?(path) && !File.directory?(path)
              File.open(path, "rb") do |file|
                puts "We got a file! Returning -#{path}-"
                headers << "HTTP/1.1 200 OK\r\n"
                headers << "Content-Type: #{content_type(file)}\r\n"
                headers << "Content-Length: #{file.size}\r\n"
                headers << "Connection: close\r\n"

                send_response(headers, nil, socket)

                if method != "HEAD"
                  IO.copy_stream(file, socket)
                end
              end
            else
              puts "We dont have a file..."
              error = "File not found!\n"
              # respond with a 404 error code to indicate the file does not exist
              headers << "HTTP/1.1 404 Not Found\r\n"
              headers << "Content-Type: text/plain\r\n"
              headers << "Content-Length: #{error.size}\r\n"
              headers << "Connection: close\r\n"

              send_response(headers, error, socket)
            end
          rescue
            puts "We have an error..."
            error = "There has been an internal server error!\n"
            # respond with a 404 error code to indicate the file does not exist
            headers << "HTTP/1.1 500 Internal Server Error\r\n"
            headers << "Content-Type: text/plain\r\n"
            headers << "Content-Length: #{error.size}\r\n"
            headers << "Connection: close\r\n"

            send_response(headers, error, socket)
          end
          finishTime = Time.now
          totalTime = (finishTime - startTime) * 1000.0
          puts "Total Time: #{totalTime}seconds."
        else
          puts "Request Line was null!"
        end
        puts "Closing socket and ending thread."
        socket.close
      end
      #thread.abort_on_exception = true
      thread.join
    end

    def content_type(path)
      ext = File.extname(path).split(".").last
      CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
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

      File.join(rootdir, *clean)
    end

    def send_response(headers, body, dest_socket)
      headers.each do |header|
        dest_socket.puts header
      end

      dest_socket.puts "\r\n"

      if body != nil
        dest_socket.puts body
      end
    end

    def new_env(request)
      if request
        # split the method and path
        method, full_path = request.split(' ')
        # split path even further
        path, query = full_path.split('?')

        input = StringIO.new
        input.set_encoding 'ASCII-8BIT'

        # pass these into the rack environment hash
        {
          'REQUEST_METHOD' => method,
          'PATH_INFO' => path,
          'QUERY_STRING' => query || '',
          'SERVER_NAME' => HOST,
          'SERVER_PORT' => PORT,
          'REMOTE_ADDR' => '127.0.0.1',
          'rack.version' => [1,3],
          'rack.input' => input,
          'rack.errors' => $stderr,
          'rack.multithread' => true,
          'rack.multiprocess' => false,
          'rack.run_once' => false,
          'rack.url_scheme' => 'http'
        }
      end
    end
  end
end
