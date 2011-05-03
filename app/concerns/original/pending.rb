class Original
  class Pending
    @queue = 'processor'
    
    class << self
      def perform
        Original.pending do |original|
          puts "Enqueueing #{original.key}"
          Resque.enqueue Original, original.key
        end
      end
    end
  end
end
