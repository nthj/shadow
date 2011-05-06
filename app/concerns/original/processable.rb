class Original
  module Processable
    include Resque::Plugins::HerokuAutoscaler

    def after_perform_publish_photo key
      notify "Publishing", key
      Photo.find_by_key(key).publish!
    end
  
    def around_perform_clean_up key
      begin
        yield
      rescue
        Original.find(key).clean!.destroy!
        
        raise
      end
    end  
  
    def around_perform_handle_deletions key
      begin
        yield
      rescue AWS::S3::NoSuchKey, MongoMapper::DocumentNotFound => e
        notify "[ERROR] Key not found", key
      rescue Errno::EPIPE => e
        puts "[ERROR] Check S3 destination (#{Asset.current_bucket}) exists and is writable"
      end
    end
    
    def around_perform_time_processors key
      time = Benchmark.realtime do
        yield
      end
      Photo.find_by_key(key).benchmark time
    end
  
    def before_perform_log_job key
      notify "Processing", key
    end
  
    def perform key
      o = find key
      return if o.processed? unless o.image?
      
      processors.each do |processor|
        notify "Applying #{(processor.name.demodulize)}", key
        begin
          processor.perform key
        rescue Exception => e
          notify "#{processor.name.demodulize} FAILED (#{e.class.name})", key
          raise e
        end
      end
    end    
  
    def processors
      Dir[Rails.root.join('app', 'concerns', 'processors', '*.rb')].map do |f| 
        "Processors::#{File.basename(f, '.rb').classify}".constantize
      end
    end
  end
end
