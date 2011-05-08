namespace :photos do
  namespace :benchmark do
    desc 'Clear processing time logs'
    task :clear => :environment do
      Photo.all.map &:clear_processing_time!
    end
    
    task :show => :environment do
      times = Photo.where(:processing_time => { :$ne => nil })

      if times.count.zero?
        puts "Benchmarks: No times available"
      else
        avg   = times.sum(&:processing_time) / times.count
        avg_s = sprintf('%.2f', avg) + ' sec'
        avg_h = 'AVG'.center(avg_s.length)
        
        pwh_s = (3600/avg).to_i.to_s
        pwh_h = 'PWH'.center(pwh_s.length)
        
        max   = (3600*50/avg).to_i.to_s.ljust(8)
        
        puts " #{ '_' * (avg_h.length + pwh_h.length + 30) } "
        puts "| #{avg_h} | #{pwh_h} | MAX/HOUR | SAMPLE SIZE |"
        puts "| #{avg_s} | #{pwh_s} | #{max} | #{times.count.to_s.ljust(11)} |"
        puts " #{ '_' * (avg_h.length + pwh_h.length + 30) } "
        puts 
        end
    end
  end

  namespace :process do
    [:preview, :showcase].each do |processor|
      desc "Re-render all #{processor.to_s.pluralize}"
      task processor => :environment do
        Photo.all.each do |photo|
          Resque.enqueue "Processors::#{processor.classify}".constantize, photo.key
        end
      end
    end
    
    desc 'Re-send data to receivers'
    task :send => :environment do
      Photo.all.map &:save
    end
  end

  namespace :queue do
    desc 'Re-process all photos'
    task :rerun => :environment do
      puts "Re-processing #{Photo.count} photos..."
      Photo.all.each do |photo|
        Resque.enqueue Original, photo.key
      end
      puts "#{Photo.count} photos queued."
    end
    
    task :originals => :environment do
      Photographer.all.each do |photographer|
        Resque.enqueue Original::Pending, :prefix => photographer.prefix
      end
    end
  end
  
  desc 'Queue new and modified photos'
  task :queue => 'queue:originals'
  
  namespace :reports do
    desc 'Show all photos'
    task :all => :environment do
      Original::Report.run
    end
    
    desc 'Show pending photos'
    task :pending => :environment do
      Original::PendingReport.run
    end
  end
  
  task :status => 'benchmark:show' do
    puts "Bucket: " + Original::Bucket.find(:max_keys => 0).name
    puts "First:  " + Original.first.key
  end
  
  desc 'Enqueue first photo'
  task :test => :environment do
    puts Resque.enqueue Original, Original.first.key
  end
end

desc 'Show photo status information'
task :photos => 'photos:status'

task :cron => 'photos:queue'
