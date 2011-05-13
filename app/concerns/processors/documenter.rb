module Processors
  class Documenter
    extend Resque::Plugins::HerokuAutoscaler
    
    class << self
      def perform key
        original = Original.find key
        original.photo.tap do |photo|
          photo.description     = original.description
          photo.dimensions      = original.dimensions
          photo.etag            = original.etag
          photo.last_modified   = original.last_modified
          photo.orientation     = original.orientation
          photo.photographed_at = original.photographed_at
          photo.photographer    = original.photographer
          photo.point           = original.point
          photo.tags            = original.tags
          photo.title           = original.title
          photo.save
        end unless original.photo == original
      end
    end
  end
end
