class Original < AWS::S3::S3Object
  module Detailed
    extend ActiveSupport::Memoizable
    
    def all
      returning image.get_exif_by_entry do |data|
        image.each_iptc_dataset do |dataset, data_field|
          data << [dataset, data_field]
        end
      end
    end

    def camera
      Camera.new exif('Make'), exif('Model')
    end

    def description
      [exif('ImageDescription'), iptc('Abstract'), iptc('Caption')].sort_by { |d| d.to_s.length }.first
    end

    def destroy!
      @image.destroy! if @image
    end

    def dimensions
      Dimensions.new exif('ExifImageLength'), exif('ExifImageWidth')
    end

    def headline
      iptc 'headline'
    end

    def iso
      exif 'ISOSpeedRatings'
    end
    
    def last_modified
      about['last-modified']
    end

    def orientation
      Orientation.from_exif exif 'orientation' 
    end

    def photographed_at
      Time.parse(exif('DateTimeOriginal').to_s.gsub(/^([0-9]{4}):([0-9]{2}):([0-9]{2})/, '\\1/\\2/\\3')).utc
    end

    def photographer
      Photographer.new.tap do |photographer|
        photographer.key  = key.photographer
        photographer.name = exif('Photographer')
      end
    end
    
    def point
      Point.new(
        Latitude.new(
          Degrees.from_string(
            exif('GPSLatitude')
          ), 
          exif('GPSLatitudeRef')
        ), 
        Longitude.new(
          Degrees.from_string(
            exif('GPSLongitude')
          ),
          exif('GPSLongitudeRef')
        )
      ) unless exif('GPSLatitude').nil? || exif('GPSLongitude').nil?
    end

    def tags
      Tag.from_keywords iptc 'keywords'
    end

    def title
      iptc 'title'
    end

    protected
      def exif key
        v = image.get_exif_by_entry(key).first.last
        v.respond_to?(:toutf8) ? v.toutf8 : v
      end

      def image
        stream_to_temporary_file
        ::Magick::Image.ping(filename).first
      end
      memoize :image

      def iptc key
        v = image.get_iptc_dataset("::Magick::IPTC::Application::#{key.humanize}".constantize)
        v.respond_to?(:toutf8) ? v.toutf8 : v
      end
  end
  
  module Processable
    def after_perform_publish_photo key
      Photo.find_by_key(key).publish!
    end
    
    def around_perform_handle_deletions key
      begin
        yield
      rescue AWS::S3::NoSuchKey, MongoMapper::DocumentNotFound => e
        Logger.info "Key not found while processing #{key}"
      end
    end
    
    def before_perform_log_job key
      Logger.info "Processing #{key}"
    end
    
    def perform key
      Dir[Rails.root.join('app', 'concerns', 'processors', '*.rb')].map { |f| 
        "Processors::#{File.basename(f, '.rb').classify}".constantize
      }.each do |processor|
        Logger.info "Applying processor #{processor} to #{key}"
        processor.perform key
      end
    end    
  end
  
  module Temporal
    extend ActiveSupport::Memoizable
    
    def clean
      File.delete filename if File.exists? filename
    end

    protected
      def stream_to_temporary_file
        FileUtils.mkdir_p File.dirname filename

        open(filename, 'wb') do |file|
          value(:reload) do |chunk|
            file.write chunk
          end
        end
      end

      def filename
        Rails.root.join 'tmp', 'processing', key
      end
      memoize :filename
  end
  
  extend ActiveSupport::Memoizable
  extend Processable
  
  include Detailed
  include Temporal
  
  set_current_bucket_to ENV['AMAZON_S3_SOURCE_BUCKET']
  
  class Bucket < AWS::S3::Bucket
    def new_object attributes = { }
      ::Original.new(attributes).tap do |object|
        register(object)
      end
    end
  end
  
  @queue = 'processor'
  
  class << self
    def find key
      key    = key.remove_extended unless key.valid_utf8?
      bucket = Bucket.find(current_bucket, :marker => key.previous, :max_keys => 1)
      if (object = bucket.objects.first) && object.key == key
        object 
      else 
        raise ::AWS::S3::NoSuchKey.new("No such key '#{key}'", bucket)
      end
    end
  
    def pending
      Bucket.find(current_bucket).objects.delete_if(&:processed?).keep_if(&:image?)
    end
  end
  
  def key
    Key.new super
  end
  
  def image?
    about['content-length'].to_i > 0
  end
  
  def processed?
    Time.parse(last_modified) <= Photo.last_processing_run
  end
end
