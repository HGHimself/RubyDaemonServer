class Measure
  def initialize
  end

  def measure_server_performace(file_name, param)
    file = File.open(file_name, "r")
    data = file.read
    file.close
    obj = '{'
    filenames = Hash.new
    data.split("\n").each do |line|
      bit = line.split(",")
      if bit.length == 6
        key = bit[param]
        str = "[\"#{bit[0]}\",\"#{bit[1]}\",#{bit[2]},#{bit[3]},#{bit[4]},#{bit[5]}]"
        if filenames.key?(key)
          filenames[key] += ",#{str}"
        else
          filenames[key] = str
        end
      end
    end
    separator = ''
    filenames.each do |key, value|
      newkey = key.split('?')
      obj += separator + "\"#{newkey[0]}\":[#{value}]"
      separator = ','
    end
    return obj + '}'
  end
end
