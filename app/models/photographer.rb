class Photographer
  include MongoMapper::EmbeddedDocument
  
  key :key,   String, :required => true, :unique => true
  key :name,  String, :required => true
end
