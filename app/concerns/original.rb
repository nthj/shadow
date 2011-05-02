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
  
  module Temporal
    extend ActiveSupport::Memoizable
    
    def clean
      File.delete filename if File.exists? filename
    end

    protected
      def stream_to_temporary_file
        FileUtils.mkdir_p File.dirname filename

        open(filename, 'w') do |file|
          value(:reload) do |chunk|
            file.write chunk
          end
        end
      end

      def filename
        Rails.root.join 'tmp', 'processing', @original.key
      end
      memoize :filename
  end
  
  extend ActiveSupport::Memoizable
  
  include Detailed
  include Temporal
  
  begin
    set_current_bucket_to ENV['AMAZON_S3_SOURCE_BUCKET']
    AWS::S3::Bucket.find current_bucket
  rescue
    AWS::S3::Bucket.create ENV['AMAZON_S3_SOURCE_BUCKET'] or raise RuntimeError, "Could not create Original bucket #{ENV['AMAZON_S3_SOURCE_BUCKET']}"
    retry
  end
  
  class Bucket < AWS::S3::Bucket
    def new_object attributes = { }
      ::Original.new(attributes).tap do |object|
        register(object)
      end
    end
  end
  
  class << self
    def pending
      Bucket.find(current_bucket).objects.delete_if(&:processed?)
    end
    
    def perform key
      Dir[Rails.root.join('app', 'concerns', 'processors', '*.rb')].map { |f| 
        "Processors::#{File.basename(f, '.rb').classify}".constantize
      }.each do |processor|
        processor.perform key
      end
    end
  end
  
  def processed?
    last_modified <= Photo.last_processing_run
  end
end
