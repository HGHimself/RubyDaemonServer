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

    #if host? then options[:host] else HOST (from config file)
    @options[:host] = !options[:host].nil? ? options[:host] : HOST
    @options[:port] = !options[:port].nil? ? options[:port] : PORT

    if !options[:timer].nil? and options[:timer] == true
      @timers = {}
    else
      @timers = nil
    end

    @router = Router.new

    server = TCPServer.new(host, port)

    if !options[:ssl].nil? and options[:ssl] == true
      if options[:key].nil? or options[:crt].nil?
        puts "Server Setup Failed!".colorize(:red)
        puts "Must include Key and Certificate files in options if 'ssl: True'.".colorize(:red)
        @server = nil
      else
        OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
        sslContext = OpenSSL::SSL::SSLContext.new
        sslContext.cert = OpenSSL::X509::Certificate.new(File.open(options[:crt]))
        sslContext.key = OpenSSL::PKey::RSA.new(File.open(options[:key]))
        sslServer = OpenSSL::SSL::SSLServer.new(server, sslContext)
        @server = OpenSSL::SSL::SSLServer.new(server, sslContext)
        puts "Listening with SSL at host: #{host} on port: #{port}".colorize(:green)
      end
    else
      @server = server
      puts "Listening at host: #{host} on port: #{port}".colorize(:green)
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

  def start_timer(val)
    @timers[val + "_start"] = Time.now if @options[:timer]
  end

  def end_timer(val)
    if @options[:timer]
      @timers[val + "_end"] = Time.now
      total = (@timers[val + "_end"] - @timers[val + "_start"]) * 1000.0
      puts ("#{total.round(4)}ms ... " + val).colorize(:light_yellow)
    end
  end

  def listen
    #on server.accept start thread
    if @server != nil
      @status = "Listening"
      begin
        socket = @server.accept
        thread = Thread.new {
          server_logic(socket)
        }
        thread.join
        @status = "Running"
      rescue Exception => ex
        puts "Error: Listen Block - #{ex.class}: #{ex.message}".colorize(:red)
        @status = "Broken"
      end
    else
      puts "Error: Could not start server!".colorize(:red)
      @status = "Broken"
    end
  end

  def server_logic(socket)
    start_timer("Thread_Exec")
    begin
      line = socket.gets

      #need proper request line
      if line != nil and line != "\r\n"
        puts line.chomp.colorize(:light_blue)

        start_timer("Form_Request")
        req = Request.new rootdir
        req.addRequestLine(line)
        req.readRequest(socket)
        end_timer("Form_Request")

        start_timer("Send_Response")
        res = Response.new socket, rootdir
        @router.doRoute req, res
        end_timer("Send_Response")

      else
        puts "RequestLine was nil".colorize(:red)
      end

      socket.close

    rescue Exception => ex
      puts "Error: Server Block - #{ex.class}: #{ex.message}".colorize(:red)
      socket.close
    end
    end_timer("Thread_Exec")
    puts "Closing Socket and Ending Thread.".colorize(:green)
    puts ""
  end

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

#
# options = {
#   timer: true,
#   ssl: true,
#   crt: "/home/hg/nodeStuff/encryption/hgking.xyz.crt",
#   key: "/home/hg/nodeStuff/encryption/server.key",
#   host: '0.0.0.0',
#   port: 12345
# }
#
# server = Server.new options
#
# server.get "/" do |req, res|
#   res.send_file(req.method, req.abs_path)
# end
#
# server.get "/test" do |req, res|
#   res.send_string(req.method, "This is a test!")
# end
#
# server.get %r"\/[a-zA-Z1-9\-\/_]*[\.]?[a-z]*" do |req, res|
#   puts "In the block"
#   res.send_file(req.method, req.abs_path)
# end
#
# server.post "/" do |req, res|
#   data = JSON.parse(req.body)
#   puts data['student']
#   res.send_file(req.method, req.abs_path)
# end
#
#
# while server.status != "Broken" do
#   server.listen
# end
