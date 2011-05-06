require 'heroku'
require 'resque/plugins/resque_heroku_autoscaler'

Resque::Plugins::HerokuAutoscaler.config do |c|
  c.heroku_user = ''
  c.heroku_pass = ENV['HEROKU_API_KEY'].to_s.split('@').last
  c.heroku_app  = ENV['HEROKU_API_KEY'].to_s.split('@').first
  c.scaling_disabled = Rails.env.development?
  
  c.new_worker_count do |pending|
    if pending.zero?
      0
    elsif pending < 3
      1
    elsif pending > 50
      50
    else
      (pending/2).ceil.to_i
      
    end
  end
end
