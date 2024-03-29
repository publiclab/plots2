Plots2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false


  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.delivery_method = :file

  #force SSL

  if config.ssl_port = 3001
    config.use_ssl = true
  end
  config.action_mailer.delivery_method = :letter_opener

  config.action_mailer.default_url_options = {
    host: 'localhost:3000'
  }
  config.action_controller.default_url_options = { host: 'localhost:3000' }
  
  # These are required to load classes into YAML, eg /test/fixtures/user_tags.yml#L129
  config.active_record.yaml_column_permitted_classes = [
    OAuth::AccessToken,
    OAuth::Consumer,
    Symbol,
    Net::HTTP,
    OpenSSL::SSL::SSLContext,
    OpenSSL::SSL::Session,
    URI::HTTPS,
    URI::RFC3986_Parser,
	  Regexp,
	  Net::HTTPOK,
	  ActiveSupport::HashWithIndifferentAccess
  ]
  
end
