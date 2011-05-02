module Processors
  class Documenter
    class << self
      def perform key
        Original.find(key).tap do |original|
          Photo.find_or_create_by_key(key).tap do |photo|
            photo.description     = original.description
            photo.dimensions      = original.dimensions
            photo.etag            = original.etag
            photo.last_modified   = original.last_modified
            photo.photographed_at = original.photographed_at
            photo.photographer    = original.photographer
            photo.point           = original.point
            photo.rating          = original.rating
            photo.tags            = original.tags
            photo.save
          end
        end
      end
    end
  end
end
