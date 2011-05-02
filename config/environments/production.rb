Shadow::Application.configure do
  config.cache_classes                      = true
  config.action_controller.perform_caching  = true
  config.action_dispatch.x_sendfile_header  = "X-Accel-Redirect"
  config.action_controller.logger           = Logger.new(STDOUT)
  config.serve_static_assets                = true
  
  config.cache_store = :dalli_store, { :expires_in => 1.day, :compress => true, :compress_threshold => 64*1024 }

  # Enable serving of images, stylesheets, and javascripts from an asset server
  config.action_controller.asset_host = Proc.new { |source|
      ["http://", [ENV['DOMAIN_ASSET_ID'], Shadow::Domains::Assets.subdomain].map(&:to_s).join('.')].join
  }
  
  config.active_support.deprecation = :notify
end
