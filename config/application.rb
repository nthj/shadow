require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Shadow
  class Application < Rails::Application
    config.encoding           = 'utf-8'
    config.filter_parameters += [:password]
    config.i18n.load_path    += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.time_zone          = 'UTC'
    config.generators do |g|
      g.integration_tool :rspec
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false, :views => false
    end
    
    %w(app/concerns app/jobs lib).each do |path|
      config.autoload_paths << Rails.root.join(path)
    end
  end
end
