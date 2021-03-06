require "./CONFIG"
require "./src/Router"
require "./src/Response"
require "./src/Request"
require 'socket'
require 'openssl'
require 'fileutils'
require 'json'

class Server

  def initialize(options)

    @options = options
    @options[:rootdir] = File.expand_path(WEB_ROOT)

    # if host? then options[:host] else HOST (from config file)
    @options[:host] = !options[:host].nil? ? options[:host] : HOST
    @options[:port] = !options[:port].nil? ? options[:port] : PORT

    if !options[:timer].nil? and options[:timer] == true
      @timers = {}
    else
      @timers = nil
    end

    # instantiate router and server
    @router = Router.new
    server = TCPServer.new(host, port)

    # need the right files for SSL
    if !options[:ssl].nil? and options[:ssl] == true
      if options[:key].nil? or options[:crt].nil?
        puts "Server Setup Failed!".colorize(:red)
        puts "Must include Key and Certificate files in options if 'ssl: True'."
        @server = nil
      else
        # create ssl context and use with server
        # OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
        sslContext = OpenSSL::SSL::SSLContext.new
        sslContext.cert = OpenSSL::X509::Certificate.new(File.open(options[:crt]))
        sslContext.key = OpenSSL::PKey::RSA.new(File.open(options[:key]))
        sslServer = OpenSSL::SSL::SSLServer.new(server, sslContext)
        @server = OpenSSL::SSL::SSLServer.new(server, sslContext)
        puts "Listening with SSL at host: #{host} on port: #{port}"
      end
    else
      @server = server
      puts "Listening at host: #{host} on port: #{port}"
      @status = "Running"
    end
    puts ""
  end

  def status
    @status
  end

  def host
    @options[:host]
  end

  def host?
    !host.nil?
  end

  def port
    @options[:port]
  end

  def port?
    !port.nil?
  end

  def rootdir
    @options[:rootdir]
  end

  # val: unique string/flag to start related timer
  def start_timer(val)
    @timers[val + "_start"] = Time.now if @options[:timer]
  end

  # ends timer created by start_timer(val)
  # val needs to have been 'started'
  def end_timer(val)
    if @options[:timer]
      @timers[val + "_end"] = Time.now
      # quick maths
      total = (@timers[val + "_end"] - @timers[val + "_start"]) * 1000.0
      #puts ("#{total.round(4)}ms ... " + val).colorize(:light_yellow)
      print (",#{total.round(4)}")
    end
  end

  # called from outside instance, preferably in infinite loop
  def listen
    if @server != nil
      @status = "Listening"
      begin
        #on server.accept start thread
        socket = @server.accept
        thread = Thread.new {
          server_logic(socket)
        }
        #prevents main thread from terminating before all threads are done
        thread.join

        @status = "Running"
      rescue Exception => ex    # cant let the server crash!
        puts "Error: Listen Block - #{ex.class}: #{ex.message},"
        @status = "Not Good"
      end
    else
      puts "Error: Could not start server!"
      @status = "Broken"
    end
  end

  # on accepted connection
  # parse request -> form response -> clean up
  def server_logic(socket)
    start_timer("Thread_Exec")
    begin

      line = socket.gets

      # need proper request line
      # (prevents any errors from getting too far)
      if line != nil and line != "\r\n" and (r_line = line.chomp.split(' ')).size == 3
        #puts line.chomp.colorize(:light_blue)
        print r_line[1]

        start_timer("Form_Request")
        req = Request.new rootdir
        # feed request line into req obj
        req.addRequestLine(line)
        # parse incoming request
        req.readRequest(socket)
        end_timer("Form_Request")

        start_timer("Send_Response")
        # set up response params
        res = Response.new socket, rootdir
        # req and res are passed to code block in functions defined below
        # provided from outside the object
        @router.doRoute req, res
        end_timer("Send_Response")
        print ",#{res.bytes}"
      end

      socket.close  # gotta clean up

    rescue Exception => ex
      puts "\nError: Server Block - #{ex.class}: #{ex.message}"
      socket.close  # gotta clean up
    end
    end_timer("Thread_Exec")
    #puts "Closing Socket and Ending Thread.".colorize(:green)
    print "\n"
  end

  # below functions add code blocks to be executed for a given
  # method and path. path can be regex :)
  #
  # need to add support for more http methods
  def get(path, &code)
    @router.form_path("GET", path, code)
  end

  def post(path, &code)
    @router.form_path("POST", path, code)
  end

  def head(path, &code)
    @router.form_path("HEAD", path, code)
  end

end
