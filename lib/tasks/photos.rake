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
  
  desc 'Map all photos onto Fusion'
  task :cartographer => :environment do
    Resque.enqueue Couriers::Fusionable
  end

  namespace :process do
    desc 'Map non-fusioned rows'
    task :coordinates => :environment do
      Photo.where(:fusion_row_id => nil).count.fdiv(10).ceil.tap do |times|
        times.times do |i|
          Photo.skip(i * times).limit(1000).fields(:id).where(:fusion_row_id => nil).each do |photo|
            Couriers::Fusionable.execute photo.id
          end
        end
      end
    end
    
    [:preview, :showcaser].each do |processor|
      desc "Re-render all #{processor.to_s.pluralize}"
      task processor => :environment do
        (Photo.count / 100).times do |i|
          Photo.skip(i * 100).limit(100).each do |photo|
            Resque.enqueue "Processors::#{processor.to_s.classify}".constantize, photo.key
          end
        end
      end
    end
    
    desc 'Re-send data to receivers'
    task :send => :environment do
      Photo.fields(:id).all.map &:carry
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
    puts "Fusion: " + Resque.redis.lrange('fusionable', 0, -1).size
  end
  
  desc 'Enqueue first photo'
  task :test => :environment do
    puts Resque.enqueue Original, Original.first.key
  end
end

desc 'Show photo status information'
task :photos => 'photos:status'

task :cron => ['photos:queue', 'photos:cartographer']
