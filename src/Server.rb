require "./CONFIG"
require "./src/Response"
require "./src/Request"
require 'socket'
require 'openssl'
require 'fileutils'
require 'json'

class Server

  def initialize(options)

    @paths = {}
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

    server = TCPServer.new(host, port)

    if !options[:ssl].nil? and options[:ssl] == true
      if options[:key].nil? or options[:crt].nil?
        puts "Server Setup Failed!".colorize(:red)
        puts "Must include Key and Certificate files in options if 'ssl: True'.".colorize(:red)
        @server = nil
      else
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
      rescue
        puts "Ahh an error".colorize(:red)
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
      puts line.chomp.colorize(:light_blue)
      #need proper request line
      if line != nil and line != "\r\n"
        start_timer("Form_Request")

        #create request object
        req = Request.new rootdir
        req.addRequestLine(line)

        bodyFlag = 0
        breakFlag = 0

        #while there are lines to get and the break flag isnt set
        while breakFlag == 0 and line = socket.gets
          #head and body in request are split by CRLF
          if line == "\r\n"
            #if this method comes with a body
            if HAS_BODY.include?(req.method)
              bodyFlag = 1
            else
              breakFlag = 1
            end
          else
            #first read headers then read body
            if bodyFlag == 0
              req.addHeader(line)
            else
              req.addToBody(line)
              puts req.bodySize
              #want to read in as many bytes as the header specifies
              if req.bodySize == req.header?("content-length").to_i or line.chomp.length < 1
                breakFlag = 1
              end
            end
          end
        end

        end_timer("Form_Request")
        start_timer("Send_Response")

        res = Response.new socket

        if @paths[req.method][req.rel_path].nil?
          if req.rel_path == "/favicon.ico"
            res.send_file(req.rel_path, req.abs_path)
          else
            curr = nil
            @paths[req.method]["REGEXP"].each do |regex, proc|
              if regex =~ req.rel_path
                curr = regex
              end
            end
            if curr != nil
              @paths[req.method]["REGEXP"][curr].call(req, res)
            else
              puts "This path has not been specified!".colorize(:red)
            end
          end
        else
          @paths[req.method][req.rel_path].call(req, res)
        end

        end_timer("Send_Response")
      else
        puts "RequestLine was nil".colorize(:red)
      end

      socket.close

    rescue Exception => ex
      puts "An error of type #{ex.class} happened, message is #{ex.message}".colorize(:red)
      socket.close
    end
    end_timer("Thread_Exec")
    puts "Closing Socket and Ending Thread.".colorize(:green)
    puts ""
  end

  def get(path, &code)
    form_path("GET", path, code)
  end

  def post(path, &code)
    form_path("POST", path, code)
  end

  def head(path, &code)
    form_path("HEAD", path, code)
  end

  def form_path(method, path, code)
    if @paths[method].nil?
      @paths[method] = {}
    end
    if Regexp == path.class
      if @paths[method]["REGEXP"].nil?
        @paths[method]["REGEXP"] = {}
      end
      @paths[method]["REGEXP"][path] = code
    else
      @paths[method][path] = code
    end
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
