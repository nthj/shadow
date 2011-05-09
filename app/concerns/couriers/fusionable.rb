module Couriers
  class Fusionable
    class InvalidFusionTableError < Exception; end 
    
    @queue = 'couriers'
    
    class << self
      extend ActiveSupport::Memoizable

      attr_accessor :username, :password, :table_id
      
      def before_perform_log_job id
        notify "Sending to Fusion Tables", Photo.find(id).key
      end

      def client
        GData::Client::FusionTables.new.tap do |c|
          c.clientlogin self.username, self.password
        end
      end
      memoize :client
    
      def table
        client.show_tables.select { |t| t.id == self.table_id }.first or raise InvalidFusionTableError
      end
      memoize :table
      
      def perform id
        photo = Photo.find id
        
        table.select("ROWID", "WHERE name=#{photo.key}").map { |id| table.delete id }
        table.insert [photo.to_kml]
      end
    end
  end
end
