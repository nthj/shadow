module Plugins
  module Couriable    
    def self.included base
      base.after_save :carry
    end
    
    def carry
      couriers.each do |courier|
        Resque.enqueue courier, id
      end
    end

    protected
      def couriers
        Dir[Rails.root.join('app', 'concerns', 'couriers', '*.rb')].map do |f| 
          "Couriers::#{File.basename(f, '.rb').classify}".constantize
        end
      end
  end
end
