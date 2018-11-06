require 'uri'

class Request

  def initialize(rootdir)
    @rootdir = rootdir
    @headers = Hash.new
    @body = ""
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

  def addRequestLine(line)
    @requestLine = line.chomp
    @method = line.split(" ")[0]

    @abs_path = requested_file(line)
    @abs_path = File.join(abs_path, 'index.html') if File.directory?(abs_path)
    puts "method:#{method} path:#{abs_path}"
  end

  def addHeader(header)
    arr = header.chomp.split(": ")
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
    @rel_path = path
    clean = []

    parts = path.split("/")

    parts.each do |part|
      next if part.empty? || part == '.'
      part == '..' ? clean.pop : clean << part
    end

    File.join(@rootdir, *clean)
  end

end
