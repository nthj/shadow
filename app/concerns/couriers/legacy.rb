module Couriers
  class Legacy
    extend Resque::Plugins::HerokuAutoscaler
    
    @queue = 'couriers'
    
    class << self
      attr_accessor :key, :destination
      
      def before_perform_log_message id
        notify "Sending to legacy app", Photo.find(id).key
      end
      
      def execute id
        Resque.enqueue self, id
      end

      def perform id
        p = Photo.fields(:description, :filename, :title).find id
        
        Net::HTTP.post_form(
          URI.parse(destination), 
          { 'key'         => key, 
            'filename'    => p.key,
            'description' => p.description,
            'title'       => p.title }
        )
      end
    end
  end
end
