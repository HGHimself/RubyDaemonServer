require 'uri'

class Request

  def initialize(rootdir)
    @rootdir = rootdir
    @headers = {}
    @body = ""
    @get = {}
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

    #while there are lines to get and the break flag isnt set
    while breakFlag == 0 and line = socket.gets
      #head and body in request are split by CRLF
      if line == "\r\n"
        #if this method comes with a body
        if HAS_BODY.include?(method)
          bodyFlag = 1
        else
          breakFlag = 1
        end
      else
        #first read headers then read body
        if bodyFlag == 0
          addHeader(line)
        else
          addToBody(line)
          puts bodySize
          #want to read in as many bytes as the header specifies
          if bodySize == header?("content-length").to_i or line.chomp.length < 1
            breakFlag = 1
          end
        end
      end
    end
  end

  def addHeader(header)
    arr = header.chomp.split(": ")
    key = arr[0].colorize(:blue)
    value = arr[1].colorize(:magenta)
    @headers[key] = value
  end

  def addToBody(string)
    puts (string.chomp + "~").colorize(:light_blue)
    @body += string
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
    end
  end
end
