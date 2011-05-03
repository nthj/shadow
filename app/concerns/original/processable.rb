class Original
  module Processable
    def after_perform_publish_photo key
      Photo.find_by_key(key).publish!
    end
  
    def around_perform_handle_deletions key
      begin
        yield
      rescue AWS::S3::NoSuchKey, MongoMapper::DocumentNotFound => e
        puts "Key not found while processing #{key}"
      end
    end
  
    def before_perform_log_job key
      puts "Processing #{key}"
    end
  
    def perform key
      Dir[Rails.root.join('app', 'concerns', 'processors', '*.rb')].map { |f| 
        "Processors::#{File.basename(f, '.rb').classify}".constantize
      }.tap do |processors|
        justifiable = processors.map(&:name).sort_by(&:length).first.length
        processors.each do |processor|
          puts "Applying #{(processor.name.demodulize + '...').ljust(justifiable)} #{key}"
          processor.perform key
        end
      end
    end    
  end
end
