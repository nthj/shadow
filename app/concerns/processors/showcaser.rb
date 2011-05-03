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
        original  = Original.find(key) or raise AWS::S3::NoSuchKey
        photo     = Photo.find_by_key(key) or raise MongoMapper::DocumentNotFound
        
             
      end
    end
  end
end
