class Original < AWS::S3::S3Object
  require 'original/bucket'
  require 'original/detailed'
  require 'original/report'
  require 'original/pending'
  require 'original/processable'
  require 'original/temporal'

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
  
  class << self    
    def find key
      # strip non-utf8 characters
      key    = key.remove_extended unless key.valid_utf8?
      bucket = Bucket.find(current_bucket, :marker => key.previous, :max_keys => 1)
      if (object = bucket.objects.first) && object.key == key
        object 
      else 
        raise ::AWS::S3::NoSuchKey.new("No such key '#{key}'", bucket)
      end
    end
    
    def first
      Bucket.find(:max_keys => 1).first
    end
    
    def pending options = { }, &block
      if block_given?
        Bucket.all(options) do |pending|
          ->(object) { yield(object) unless object.processed? }.call(pending)
        end
      else
        Bucket.all(options).delete_if &:processed?
      end
    end
  end
  
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
