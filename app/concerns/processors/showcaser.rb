# 
# SHOWCASER
#
# Make a large photo
# Watermark it
# 
module Processors
  class Showcaser
    class << self
      def perform key
        original  = Original.find key or raise Original::ObjectNotFound
        photo     = Photo.find key or raise MongoMapper::DocumentNotFound
        
             
      end
    end
  end
end
