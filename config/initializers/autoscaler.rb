require 'heroku'
require 'resque/plugins/resque_heroku_autoscaler'

module Resque::Plugins::HerokuAutoscaler
  alias set_workers_without_cache set_workers
  def set_workers number_of_workers
    Rails.cache.fetch('heroku.worker.refresh', :expires_in => 10.seconds) do
      Rails.cache.write('heroku.worker.count', set_workers_without_cache(number_of_workers), :expires_in => 1.minute)
    end
  end
  
  alias current_workers_without_cache current_workers
  def current_workers
    Rails.cache.fetch('heroku.worker.count', :expires_in => 1.minute) do
      current_workers_without_cache.tap do |count|
        Rails.cache.delete 'heroku.worker.refresh' if count.zero?
      end
    end
  end
end

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
