namespace :photos do
  desc 'Show all photos'
  task :all => :environment do
    Original::Report.run
  end
  
  desc 'Show average processing time'
  task :benchmark => :environment do
    times = Photo.where(:processing_time => { :$ne => nil })
    if times.count.zero?
      puts "Sorry, no times to sample from."
    else
      avg = times.sum(&:processing_time) / times.count
      puts "Average: #{sprintf('%.2f', avg)} seconds, or ~#{(3600/avg).ceil}/worker/hour, or maximum of #{(3600/avg).ceil * 50}/hour (sampling #{times.count} photos)"
    end
  end
  
  desc 'Show bucket'
  task :bucket => :environment do
    puts Original::Bucket.find(:max_keys => 0).inspect
  end
  
  desc 'Show first photo'
  task :first => :environment do
    puts Original.first.inspect
  end
  
  desc 'Show pending photos'
  task :pending => :environment do
    Original::PendingReport.run
  end
  
  namespace :process do
    desc 'Mark all photos as pending'
    task :clear => :environment do
      Photo.all.map &:clear!
    end
    
    desc 'Process any photos modified since last run'
    task :pending => :environment do
      Photographer.all.each do |photographer|
        Resque.enqueue Original::Pending, :prefix => photographer.prefix
      end
    end
    
    desc 'Process all photos currently in database'
    task :reprocess => :environment do
      puts "Re-processing #{Photo.count} photos"
      Photo.all.each do |photo|
        Resque.enqueue Original, photo.key
      end
    end
    
    desc 'Process all photos'
    task :all => [:clear, :pending]
  end
  
  task :process => 'process:pending'
  
  desc 'Enqueue first photo'
  task :test => :environment do
    puts Resque.enqueue Original, Original.first.key
  end
end

task :cron => 'photos:process'
