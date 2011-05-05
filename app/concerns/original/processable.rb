class Original
  module Processable
    include Resque::Plugins::HerokuAutoscaler

    def after_perform_publish_photo key
      puts "Publishing... ".ljust(justifiable + 10) + key
      Photo.find_by_key(key).publish!
    end
  
    def around_perform_handle_deletions key
      begin
        yield
      rescue AWS::S3::NoSuchKey, MongoMapper::DocumentNotFound => e
        puts "[ERROR] Key not found while processing #{key}"
      end
    end
    
    def around_perform_time_processors key
      time = Benchmark.realtime do
        yield
      end
      Photo.find_by_key(key).benchmark time
    end
  
    def before_perform_log_job key
      puts "Processing... ".ljust(justifiable + 10) + key
    end
    
    def justifiable
      processors.map(&:name).sort_by(&:length).first.length
    end
  
    def perform key
      o = find key
      return if o.processed? unless o.image?
      
      processors.each do |processor|
        puts "Applying #{(processor.name.demodulize + '...').ljust(justifiable)} #{key}"
        begin
          processor.perform key
        rescue Exception => e
          puts "[ERROR] #{processor.name.demodulize} failed to apply (#{e.class.name})"
          raise e
        end
      end
    end    
  
    protected
      def processors
        Dir[Rails.root.join('app', 'concerns', 'processors', '*.rb')].map do |f| 
          "Processors::#{File.basename(f, '.rb').classify}".constantize
        end
      end
  end
end
