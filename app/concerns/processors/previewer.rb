# 
# PREVIEWER
#
# Make a thumbnail
#
module Processors
  class Previewer
    class << self
      def perform key
        Original.find(key).compress(70).resize(280, 167).to(:fit).save(:medium)
      end
    end
  end
end
