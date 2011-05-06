class Original
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
      self
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
      Time.parse(exif('DateTimeOriginal').to_s.gsub(/^([0-9]{4}):([0-9]{2}):([0-9]{2})/, '\\1/\\2/\\3')).utc rescue nil
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
end
