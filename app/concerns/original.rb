class Original < AWS::S3::S3Object
  extend ActiveSupport::Memoizable
  extend Processable
  
  include Compressable
  include Detailed
  include Resizable
  include Savable
  include Temporal
  include Watermarkable
    
  set_current_bucket_to ENV['AMAZON_S3_SOURCE_BUCKET']
  
  @queue = 'processor'
  
  def etag
    about['etag']
  end
  
  def key
    Key.new super
  end
  
  def image?
    key.image? && about['content-length'].to_i > 0
  end
  
  def photo
    Photo.find_or_create_by_key(key)
  end
  
  def processed?
    photo == self
  end
end
