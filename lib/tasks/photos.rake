namespace :photos do
  desc 'Show all photos'
  task :all => :environment do
    Original::Report.run
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
      Resque.enqueue Original::Pending
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
