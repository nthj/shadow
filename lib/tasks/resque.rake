require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

task "resque:cleanup" => :environment do
  Resque.workers.map &:done_working
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
