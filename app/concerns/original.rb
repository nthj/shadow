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
  
  def key
    Key.new super
  end
  
  def image?
    key.image? && about['content-length'].to_i > 0
  end
  
  def processed?
    Time.parse(last_modified) <= Photo.last_processing_run
  end
end
