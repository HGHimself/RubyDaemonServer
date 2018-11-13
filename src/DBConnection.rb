require 'mongo'

class DBConnection

  def initialize(db)
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => db)
  end

  def client
    @client
  end

  def find_all_and_iterate(table, &code)
    client[table].find.each_with_index do |doc, i|
      code.call(doc, i)
    end
  end

end
