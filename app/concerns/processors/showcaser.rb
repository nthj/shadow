# 
# SHOWCASER
#
# Make a large photo
# Watermark it
# 
module Processors
  class Showcaser
    extend Resque::Plugins::HerokuAutoscaler
    
    @queue = 'processors'
    
    class << self
      def perform key
        Original.find(key).compress(100).resize(2500, 1667).to(:fit).watermark.save
      end
    end
  end
end
