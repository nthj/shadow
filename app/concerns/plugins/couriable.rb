module Plugins
  module Couriable    
    def self.included base
      base.after_save :carry
      base.after_save :mark_as_carried
      base.key :carried_at, Time
    end
    
    def carry
      couriers.each do |courier|
        courier.execute id
      end if couriable?
    end

    protected
      def couriable?
        !self.carried_at? || self.carried_at < 3.seconds.ago
      end
      
      def couriers
        Dir[Rails.root.join('app', 'concerns', 'couriers', '*.rb')].map do |f| 
          "Couriers::#{File.basename(f, '.rb').classify}".constantize
        end
      end
      
      def mark_as_carried
        self.carried_at = Time.now
      end
  end
end
