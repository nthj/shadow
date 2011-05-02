require 'mongo_mapper'

begin
  MongoMapper.config = {
    :database => {
      'uri' => ENV["MONGO_#{Rails.env.upcase}_URL"] || ENV['MONGOHQ_URL']
    }
  }
  MongoMapper.connect :database
rescue URI::InvalidURIError => e
  raise RuntimeError, "Could not connect to Mongo database: check MONGOHQ_URL"
end
