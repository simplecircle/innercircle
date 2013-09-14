Innercircle::Application.configure do

 config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => '25',
    :domain => "getinnercircle.com",
    :authentication => :plain,
    :user_name => "elliottg",
    :password => "sendgridbot"
  }

  # Code is not reloaded between requests
  config.cache_classes = true
  config.lograge.enabled = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true
  config.assets.debug = true
  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # This prevents it from being pushed up to Cloudfiles with all the other things in public/assets
  config.assets.manifest = Rails.root.join("public/")

  # Add the fonts path
  config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( .svg .eot .woff .ttf )

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = "http://fbb10cc56329cb5ea057-4ca1418a7613371d048778718c3acae9.r81.cf1.rackcdn.com"


  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
