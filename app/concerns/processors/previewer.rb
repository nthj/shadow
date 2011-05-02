# 
# PREVIEWER
#
# Make a thumbnail
#
module Processors
  class Previewer
    class << self
      def perform key
        original  = Original.find key or raise Original::ObjectNotFound
        photo     = Photo.find key or raise MongoMapper::DocumentNotFound 
        
        # process photo into thumbnail
        # save asset
      end
    end
  end
end
