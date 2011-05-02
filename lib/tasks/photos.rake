namespace :photos do
  desc 'Show pending photos'
  task :pending => :environment do
    Original.pending.each do |original|
      puts "#{original.key} - #{original.about['last-modified']}"
      puts "... (#{Original.pending.count - 15} more)" and break if count ||= 0 and count > 15
    end
    puts "No photos pending." if Original.pending.blank? 
  end
  
  desc 'Process any photos run since '
  task :process => :environment do
    Original.pending.each do |original|
      Resque.enqueue Original, original.key
    end
  end
end

task :cron => :process
