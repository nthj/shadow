# 
# PREVIEWER
#
# Make a thumbnail
#
module Processors
  class Previewer
    class << self
      def perform key
        Original.find(key).compress(70).resize(250, 250).to(:fit).save(:medium)
      end
    end
  end
end
