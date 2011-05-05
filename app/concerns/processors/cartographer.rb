# 
# CARTOGRAPHER
# 
# Look up address information from the Photo's GPS coordinates
# Rate-limited 

module Processors
  class Cartographer
    extend Processors::Extensions::RateLimitable
    extend Resque::Plugins::HerokuAutoscaler
    
    @limit = 1.second

    class << self
      def perform key
        
      end
    end
  end
end
