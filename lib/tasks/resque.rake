require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

task "resque:cleanup" => :environment do
  Resque.redis.smembers(:workers).count.times { Resque.redis.spop(:workers) }
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
