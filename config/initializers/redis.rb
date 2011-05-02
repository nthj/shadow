require 'resque/server'

begin
  uri           = URI.parse(ENV["REDIS_#{Rails.env.upcase}_URL"] || ENV['REDISTOGO_URL'])
  Resque.redis  = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :db => uri.path[1..-1] || '0')
rescue URI::InvalidURIError => e
  raise RuntimeError, "Could not connect to Redis database: check REDISTOGO_URL"
end
