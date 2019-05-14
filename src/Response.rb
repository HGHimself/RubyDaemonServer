class Response

  def initialize(socket, rootdir)
    @rootdir = rootdir
    @socket = socket
    @headers = Array.new
    @bytes = 0
  end

  def bytes
    @bytes
  end

  # queue up headers for reponse
  # best used outside server object, before sending data
  def add_header(header)
    @headers.push(header)
  end

  def get_path(file)
    return File.expand_path(File.join(@rootdir, file))
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
      @bytes = IO.copy_stream(file, @socket)
      file.close
    end
  end

  # tool to send a certain file
  def send_file(method, path)
    if File.exist?(path) && !File.directory?(path)
      @code = 200
    else
      path = get_path(NOT_FOUND_PAGE)
      # respond with a 404 error code to indicate the file does not exist
      @code = 404
    end

    begin
      form_response(method, path, @code)
    rescue
      # any error needs a 500:server error response
      error()
    end
    return @bytes
  end

  def error
    path = get_path(SERVER_ERR_PAGE)
    @code = 500
    form_response(method, path, @code)
  end

  # used like regular IO puts, good for custom response
  def put(line)
    @socket.puts line.chomp + "\r\n"
  end

  # sends valid response with given string as body
  def send_string(method, string)
    @bytes = string.length
    if @bytes
      @code = 200
      @socket.puts "HTTP/1.1 #{@code} #{STATUS_CODES[@code]}\r\n"
      @socket.puts "Content-Type: #{CONTENT_TYPE_MAPPING['txt']}\r\n"
      @socket.puts "Content-Length: #{string.size}\r\n"
      @socket.puts "Connection: close\r\n"
      @socket.puts "\r\n"
      @socket.puts string
    else
      path = get_path(SERVER_ERR_PAGE)
      @code = 500
      form_response(method, path, @code)
    end
    return @bytes
  end

end
