class Response
  def initialize(socket, rootdir)
    @rootdir = rootdir
    @socket = socket
    @headers = Array.new
  end

  # queue up headers for reponse
  # best used outside server object, before sending data
  def addHeader(header)
    @headers.push(header)
  end

  # tool to send a certain file
  def send_file(method, path)
    if File.exist?(path) && !File.directory?(path)
      code = 200
    else

      path = File.expand_path(File.join(@rootdir, NOT_FOUND_PAGE))
      puts path
      # respond with a 404 error code to indicate the file does not exist
      code = 404
    end

    begin
      form_response(method, path, code)
    rescue
      # any error needs a 500:server error response
      path = File.expand_path(File.join(@rootdir, SERVER_ERR_PAGE))
      code = 500
      form_response(method, path, code)
    end

    return code
  end

  def content_type(path)
    ext = File.extname(path).split(".").last
    CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
  end

  # sends properly formatted response over socket
  def form_response(method, path, code)
    File.open(path, "rb") do |file|
      @socket.puts "HTTP/1.1 #{code} #{STATUS_CODES[code]}\r\n"
      @headers.each do |header|
        @socket.puts header
      end
      @socket.puts "Content-Type: #{content_type(file)}\r\n"
      @socket.puts "Content-Length: #{file.size}\r\n"
      @socket.puts "Connection: close\r\n"
      @socket.puts "\r\n"
      IO.copy_stream(file, @socket)
      file.close
    end
  end

  # used like regular IO puts, good for custom response
  def put(line)
    @socket.puts line.chomp + "\r\n"
  end

  # sends valid response with given string as body
  def send_string(method, string)
    code = 200
    @socket.puts "HTTP/1.1 #{code} #{STATUS_CODES[code]}\r\n"
    @socket.puts "Content-Type: #{CONTENT_TYPE_MAPPING['txt']}\r\n"
    @socket.puts "Content-Length: #{string.size}\r\n"
    @socket.puts "Connection: close\r\n"
    @socket.puts "\r\n"
    @socket.puts string

    return code
  end
end
