module Plugins
  module Couriable    
    def self.included base
      base.after_save :carry
    end
    
    def carry
      couriers.each do |courier|
        courier.execute id
      end if couriable?
    end

    protected
      def couriable?
        !self.updated_at? || self.updated_at < 10.seconds.ago
      end
      
      def couriers
        Dir[Rails.root.join('app', 'concerns', 'couriers', '*.rb')].map do |f| 
          "Couriers::#{File.basename(f, '.rb').classify}".constantize
        end
      end
  end
end
