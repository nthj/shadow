module Processors
  class Courier
    extend Resque::Plugins::HerokuAutoscaler
    
    class << self
      def perform key
        # Receivers
        # send to Google
        # send to legacy above photography system
      end
    end
  end
end
