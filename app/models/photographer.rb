class Photographer
  include MongoMapper::EmbeddedDocument
  
  embedded_in :photo
  
  key :key,   String, :required => true, :unique => true
  key :name,  String, :required => true
  
  class << self
    def all
      [Photographer.new(:key => 'above-photography', :name => 'Above Photography')]
    end
  end
  
  def prefix
    key + '/'
  end
end
