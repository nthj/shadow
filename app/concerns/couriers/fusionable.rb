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
        puts "Selecting Fusion Table (#{self.table_id})" unless class_variable_defined? :@@table
        @@table ||= client.show_tables.select { |t| t.id == self.table_id }.first or raise InvalidFusionTableError
      end
      
      def perform
        while id = Resque.redis.lpop('fusionable')
          begin
            photo = Photo.find id
          
            notify "Adding to Fusion Tables", photo.key
            
            if photo.fusion_row_id
              data = table.encode([photo.to_fusion]).first
              data = data.to_a.map{|x| x.join("=")}.join(", ")
              sql = "UPDATE #{self.table_id} SET #{data} WHERE ROWID = '#{photo.fusion_row_id}'"
              GData::Client::FusionTables::Data.parse(client.sql_post(sql)).body
              sleep 0.2
            else
              table.insert [photo.to_fusion] rescue nil
              table.select("ROWID", "WHERE name='#{photo.key}'").map(&:values).map(&:first).map do |id|
                photo.fusion_row_id = id
                photo.save
              end
              sleep 0.4
            end
          rescue => e
            puts e.message
            notify "Fusion Tables failed", id
          end
        end
      end
    end
  end
end
