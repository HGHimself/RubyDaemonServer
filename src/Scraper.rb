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
      links = doc.xpath('//*[@id="gs_res_ccl_mid"]/div/div/h3/a')
      phrases = doc.xpath('//*[@id="gs_res_ccl_mid"]/div/div/div[1]')
      desc = doc.xpath('//*[@id="gs_res_ccl_mid"]/div/div/div[2]')

      if !links.nil? and links.size > 0
        links.each_with_index do |var, i|
          puts "-"
          doc = {
            :_id => var.attribute("href"),
            :title => var.innerHTML,
            :blurb => strip_tags(phrases[i].inner_html),
            :link => var.attribute("href"),
            :desc => strip_tags(desc[i].to_s),
          }

          client[:GoogleScholar].insert_one doc
        end
        return 1
      else
        puts "null"
        return 0
      end
    rescue
      puts "arrgh there be an error"
    end
  end

  def doWork(query)
    Mongo::Logger.logger.level = ::Logger::FATAL

    client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'scraper')

    offset = 0
    string = "https://scholar.google.com/scholar?start=#{offset}&q=#{query}&hl=en&as_sdt=0,26"
    res = scrape(string, client)
    #while 1 ==  do
      offset += 10
      string = "https://scholar.google.com/scholar?start=#{offset}&q=#{query}&hl=en&as_sdt=0,26"
    #end

    #client[:cars].insert_one doc
    html = "<table>"
    client[:cars].find.each_with_index do |doc, i|
      if i == 0
        doc.each do |key, value|
          html += "<th>#{key}</th>"
        end
      end
      html += "<tr>"
      doc.each do |key, value|
        html += "<td>#{value}</td>"
      end
      html += "</tr>"
    end
    html += "</table>"

    client.close
    return html
  end
end
