class Original
  class Report
    class << self
      include ActionView::Helpers::DateHelper
      
      def run
        objects.each do |original|
          puts "#{titleize(original.key)}   #{time_ago_in_words original.last_modified}"
        end
      end
      
      protected
        def longest_key_length
          objects.any? ? objects.sort_by { |o| o.key.length }.reverse.first.key.length : 0
        end

        def objects
          @objects ||= Original::Bucket.all
        end
      
        def titleize key
          key.ljust longest_key_length
        end
    end
  end 
  
  class PendingReport < Report
    class << self
      def run
        super
      
        if objects.any?
          puts "(#{objects.count} total)"
        else
          puts "No photos pending."
        end
      end
    
      protected
        def objects
          @objects ||= Original.pending
        end
    end
  end
end
