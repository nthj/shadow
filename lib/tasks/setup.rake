desc 'Initial Heroku setup'
task :setup => :environment do
  abort "Please sign up for Heroku: http://heroku.com" unless `which heroku`
  Setup.setup_heroku_app
  
  Setup.config 'AMAZON_ACCESS_KEY_ID',          'Amazon Access Key ID'
  Setup.config 'AMAZON_SECRET_ACCESS_KEY'
  Setup.config 'AMAZON_S3_SOURCE_BUCKET',       'S3 source bucket name',      'where your original or master photos reside'
  Setup.config 'AMAZON_S3_DESTINATION_BUCKET',  'S3 destination bucket name', 'which S3 bucket to place your processed photos'
  Setup.config 'GOOGLE_MAPS_API_KEY',           'Google Maps API key',        'http://code.google.com/apis/maps/signup.html'

  Setup.execute
end

class Setup
  @config = { }
  
  class << self
    def config key, label = nil, explanation = nil
      label ||= key.titleize
      label << " (#{explanation})" if explanation.present?
      label << ": "
      puts label
      @config[key] = $stdin.gets.chomp
      puts ""
    end
    
    def execute
      puts `heroku config:add #{@config.map { |c| c.join("=") }.join(' ')}`
      puts "Add Memcache, MongoHQ, and RedisToGo addons? (free, y/n)"
      ['memcache:5mb', 'mongohq:free', 'redistogo:nano'].each do |addon|
        puts `heroku addons:add #{addon}`
      end if ['y', 'yes'].include?($stdin.gets.chomp.downcase)
    end
    
    def setup_heroku_app
      if `git remote -v` =~ /heroku/
        app = `git remote -v`.match(/git@heroku\.[\w]+:([\w\-]+)\.git/)[1]
      else
        puts "Create Heroku app with name: "
        `heroku create #{app = $stdin.gets.chomp}`        
      end
      
      @config['HEROKU_API_KEY'] = "#{app}@#{`tail -1 ~/.heroku/credentials`}".chomp
    end
    
  end
end
