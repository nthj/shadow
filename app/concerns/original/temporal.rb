class Original
  module Temporal
    extend ActiveSupport::Memoizable

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
end
