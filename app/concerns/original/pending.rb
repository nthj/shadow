class Original
  class Pending
    extend Resque::Plugins::HerokuAutoscaler
    
    @queue = 'processor'
    
    class << self
      def perform options = { }
        Original::Bucket.all(options).each do |original|
          notify "Enqueueing", original.key
          Resque.enqueue Original, original.key
        end
      end
    end
  end
end
