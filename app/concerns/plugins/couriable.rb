module Plugins
  module Couriable    
    def self.included base
      base.after_save :carry
    end
    
    def carry
      couriers.each do |courier|
        courier.execute id
      end unless fusion_row_id_changed?
    end

    protected
      def couriers
        Dir[Rails.root.join('app', 'concerns', 'couriers', '*.rb')].map do |f| 
          "Couriers::#{File.basename(f, '.rb').classify}".constantize
        end
      end
  end
end
