class Original
  class Pending
    @queue = 'processor'
    
    class << self
      def perform options = { }
        Original::Bucket.all(options).each do |original|
          puts "Enqueueing...".ljust(original.class.justifiable + 10) + original.key
          Resque.enqueue Original, original.key
        end
      end
    end
  end
end
