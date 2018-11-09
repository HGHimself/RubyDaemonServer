require 'mongo'
require 'nokogiri'
require 'open-uri'

class Scraper
  def strip_tags(string)
    string.gsub( %r{</?[^>]+?>}, '' )
  end

  def scrape(string, client)
    puts string
    begin
      doc = Nokogiri::HTML(open(string))
      names = doc.xpath('//*[@id="mw-content-text"]/div/table[2]/tbody/tr/th/a')
      hex_plural = doc.xpath('//*[@id="mw-content-text"]/div/table[2]/tbody/tr/td[1]')

      if !names.nil? and names.size > 0
        hex_plural.size.times do |i|
          doc = {
            :name =>  names[i + 9].inner_html,
            :hex => hex_plural[i].inner_html,
            :link => "https://en.wikipedia.org/" + names[i + 9].attribute("href"),
          }

          client[:Colors].insert_one doc
        end
        return 1
      else
        puts "null"
        return 0
      end
    rescue Exception => ex
      puts "arrgh there be an error"
      puts ex
    end
  end

  def doWork(query)

    Mongo::Logger.logger.level = ::Logger::FATAL
    inputs = ["List_of_colors:_A–F","List_of_colors:_G–M","List_of_colors:_N-Z"]
    client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'scraper')
    if !query.nil? and inputs.include?(query)
      string = "https://en.wikipedia.org/wiki" + query
      res = scrape(string, client)
    end


    open_table = "<table>"
    lines = ""
    headers = ""
    client[:Colors].find.each_with_index do |doc, i|
      line = ""
      hex = ""
      if i == 0
        doc.each do |key, value|
          headers += "<th>#{key}</th>" if key != '_id'
        end
      end
      data = ""
      doc.each do |key, value|
        if key == "hex"
          hex = value.chomp
        end
        # if key == "link"
        #   value = "<a href='#{value.chomp}'>Link</a>"
        # end
        data += "<td>#{value.chomp}</td>" if key != "_id"
      end
      line = "<tr style='background-color: " + hex + "'>" + data + "</tr>"
      lines += line
    end
    close_table = "</table>"

    client.close
    return open_table + headers + lines + close_table
  end
end
