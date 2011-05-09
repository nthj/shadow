# 
# PREVIEWER
#
# Make a thumbnail
#
module Processors
  class Previewer
    cattr_reader :height, :width
    
    @@height, @@width = [167, 270]
    
    extend Resque::Plugins::HerokuAutoscaler
    
    class << self
      def perform key
        Original.find(key).compress(70).resize(@@width, @@height).to(:fit).save(:medium)
      end
    end
  end
end
