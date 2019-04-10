
class Templator

  def initialize
    @object_pool = {}
    @string = ""
  end

  def string
    @string
  end

  def translate(path)
    if File.exist?(path) && !File.directory?(path)
      File.open(path, "rb") do |file|
        parse file
        close file
      end
    else
      puts "No file here boss"
    end
  end

  def parse(file)
    while file.length
      @string = file[0..1]
      parse file[1..-1]
    end
  end
end
