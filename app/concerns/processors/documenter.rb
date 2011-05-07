module Processors
  class Documenter
    extend Resque::Plugins::HerokuAutoscaler
    
    class << self
      def perform key
        Original.find(key).photo.tap do |photo|
          photo.description     = original.description
          photo.dimensions      = original.dimensions
          photo.etag            = original.etag
          photo.last_modified   = original.last_modified
          photo.photographed_at = original.photographed_at
          photo.photographer    = original.photographer
          photo.point           = original.point
          photo.tags            = original.tags
          photo.title           = original.title
          photo.save
        end
      end
    end
  end
end
