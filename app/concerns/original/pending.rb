class Original
  class Pending
    @queue = 'processor'
    
    class << self
      def perform prefix = nil
        Original.pending(:prefix => prefix) do |original|
          puts "Enqueueing...".ljust(original.justifiable + 10) + original.key
          Resque.enqueue Original, original.key
        end
      end
    end
  end
end
