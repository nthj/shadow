module Couriers
  class Fusionable
    class InvalidFusionTableError < Exception; end 
  
    extend Resque::Plugins::HerokuAutoscaler
    
    @queue = 'couriers'
    
    class << self
      extend ActiveSupport::Memoizable

      attr_accessor :username, :password, :table_id
      
      def client
        GData::Client::FusionTables.new.tap do |c|
          c.clientlogin self.username, self.password
        end
      end
      memoize :client
      
      def execute id
        notify "Adding to Fusionable queue", Photo.find(id).key
        Resque.redis.rpush 'fusionable', id
      end
    
      def table
        client.show_tables.select { |t| t.id == self.table_id }.first or raise InvalidFusionTableError
      end
      memoize :table
      
      def perform
        while id = Resque.redis.lpop('fusionable')
          photo = Photo.find id
        
          table.select("ROWID", "WHERE name='#{photo.key}'").map(&:values).map(&:first).map { |id| table.delete id }
          table.insert [photo.to_fusion]
          sleep 1
        end
      end
    end
  end
end
