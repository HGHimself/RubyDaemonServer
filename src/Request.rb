require 'uri'

class Request

  def initialize(rootdir)
    @rootdir = rootdir
    @headers = {}
    @body = ""
    @get = {}
    @post = {}
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

  def get?(param)
    if !@get[param].nil?
      @get[param]
    else
      nil
    end
  end

  def post?(param)
    if !@post[param].nil?
      @post[param]
    else
      nil
    end
  end

  def addRequestLine(line)
    @requestLine = line.chomp
    @method = line.split(" ")[0]

    getParams(line)

    @abs_path = requested_file(line)
    @abs_path = File.join(abs_path, 'index.html') if File.directory?(abs_path)
    puts "method:#{method} path:#{abs_path}".colorize(:light_green)
  end

  def readRequest(socket)

    bodyFlag = 0
    breakFlag = 0

    #while the socket doesnt return a CRLF
    while "" != line = socket.gets.chomp do
      # get every single header
      #puts line.colorize(:magenta)
      addHeader(line.downcase)
    end

    if HAS_BODY.include?(method)
      size = header?("content-length").to_i
      addToBody(socket.read(size))
      parseBody
    end

  end

  def addHeader(header)
    arr = header.chomp.split(": ")
    key = arr[0]
    if arr[1][0..9] == "multipart/"
      arr2 = arr[1].split("; ")
      value = arr2[0]
      @headers[key] = value
      @headers[arr2[1].split('=')[0]] = arr2[1].split('=')[1]
    else
      value = arr[1]
      @headers[key] = value
    end
  end

  def addToBody(string)
    puts (string + "~" + string.size.to_s).colorize(:light_blue)
    @body += string
    puts bodySize
  end

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

  def parseBody
    if header?("content-type") == "application/x-www-form-urlencoded"
      body.split("&").each do |var|
        vals = var.split("=")
        @post[vals[0]] = vals[1]
      end
    end
  end
end
