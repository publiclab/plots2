Plots2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Add non-concatenated scripts
  config.assets.precompile += ['dragdrop.js', 'post.js']

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  # config.middleware.insert_before ActionDispatch::Static, Rack::SSL, :exclude => proc { |env| env['HTTPS'] != 'on' }

  # Set to `:info` to match the current default, or set to `:debug` to opt-into
  # the future default.
  config.log_level = :info

  # Prepend all log lines with the following tags
  config.log_tags = [ :request_id ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_name_prefix = "railsdiff_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.delivery_method = :sendmail

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
  :address => "smtp",
  :port => 25,
  }

  # Enable threaded mode
  # config.threadsafe!

  config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = {
    host: 'unstable.publiclab.org'
  }
  config.action_controller.default_url_options = { host: 'unstable.publiclab.org' }

end
