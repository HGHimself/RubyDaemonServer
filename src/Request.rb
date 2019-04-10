require 'uri'

class Request

  def initialize(rootdir)
    # needs to be given the root directory information
    # maybe not the best move??
    @rootdir = rootdir
    @headers = {}
    @body = ""
    @get = {}
    @post = {}
    @addr = ""
  end

  def method
    @method
  end

  def rel_path
    @rel_path
  end

  def abs_path
    @abs_path
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

  def addr
    @addr
  end
  # access the GET param
  def get?(param)
    if !@get[param].nil?
      @get[param]
    else
      nil
    end
  end

  # access the POST param
  def post?(param)
    if !@post[param].nil?
      @post[param]
    else
      nil
    end
  end

  # primes request with method and path
  def addRequestLine(line)
    @requestLine = line.chomp
    @method = line.split(" ")[0]

    # reads GET parameters from query string
    getParams(line)

    # convert relative path to absolute
    @abs_path = requested_file(line)
    @abs_path = File.join(abs_path, 'index.html') if File.directory?(abs_path)
    puts "method:#{method} path:#{abs_path}".colorize(:light_green)
  end

  # parses request message from socket
  def readRequest(socket)
    # this returns the IP address of the request
    @addr = socket.peeraddr[2]

    # while the socket doesnt return a CRLF
    while "" != line = socket.gets.chomp do
      # get every single header
      #puts line.colorize(:magenta)
      addHeader(line.downcase)
    end

    if HAS_BODY.include?(method)
      # read the specified number of bytes in the body
      size = header?("content-length").to_i
      addToBody(socket.read(size))
      parseBody
    end

  end

  # add singular header to assoc array 'headers'
  def addHeader(header)
    # format => "header: value\r\n"
    arr = header.chomp.split(": ")
    key = arr[0]
    # grab boundary off "content-type: multipart/<whatever>; boundary= ---12345"
    if arr[1][0..9] == "multipart/"
      arr2 = arr[1].split("; ")
      value = arr2[0]
      @headers[key] = value # ["content-type:"] = "multipart/<whatever>"
      @headers[arr2[1].split('=')[0]] = arr2[1].split('=')[1]
  else  # normally it's this case
      value = arr[1]
      @headers[key] = value
    end
  end

  # concat data onto the body string
  def addToBody(string)
    puts (string + "~" + string.size.to_s).colorize(:light_blue)
    @body += string
    puts bodySize
  end

  # figure out which file
  def requested_file(request)
    uri = request.split(" ")[1]
    path = URI.unescape(URI(uri).path)

    @rel_path = path
    clean = []

    parts = path.split("/")

    parts.each do |part|
      next if part.empty? || part == '.'
      part == '..' ? clean.pop : clean << part
    end

    File.join(@rootdir, *clean)
  end

  # breaks request line and gets query parameters
  def getParams(line)
    uri = line.split(" ")[1]
    parts = uri.split("?")
    if parts.size > 1
      parts[1].split("&").each do |var|
        vals = var.split("=")
        @get[vals[0]] = vals[1]
      end
      @get.each do |key, val|
        puts "key: #{key} ~~ val: #{val}"
      end
    end
  end

  # POST parameters come in the body
  # need to parse those guys
  def parseBody
    if header?("content-type") == "application/x-www-form-urlencoded"
      body.split("&").each do |var|
        vals = var.split("=")
        @post[vals[0]] = vals[1]
      end
    end
  end
end
