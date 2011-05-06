class Original
  module Temporal
    extend ActiveSupport::Memoizable
    
    def clean!
      File.delete original_filename rescue nil
      File.delete filename rescue nil
    end

    protected
      def original_filename
        Rails.root.join('tmp', 'originals', key)
      end
      
      def stream_to_temporary_file
        FileUtils.mkdir_p File.dirname filename
        
        FileUtils.copy s3, filename
      end
      
      def s3
        unless File.exists? original_filename
          FileUtils.mkdir_p File.dirname original_filename
          
          open(original_filename, 'wb') do |file|
            value(:reload) do |chunk|
              file.write chunk
            end
          end
        end
        original_filename
      end

      def filename
        Rails.root.join 'tmp', 'processing', key
      end
      memoize :filename
  end
end
