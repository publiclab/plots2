require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/cors'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups)
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Plots2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :sidekiq

    # Enable the asset pipeline
    config.assets.enabled = true

    I18n.available_locales = [:en, :de, "zh-CN", :ar, :es, "hi-IN", :it, :ko, "pt-BR", :ru]
    config.i18n.default_locale = :en

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # rails will fallback to config.i18n.default_locale translation
    config.i18n.fallbacks = true

    # rails will fallback to en, no matter what is set as config.i18n.default_locale
    config.i18n.fallbacks = [:en]

    config.action_view.sanitized_allowed_tags = ['iframe', 'embed']
    config.action_dispatch.default_headers.merge!({'X-Frame-Options' => 'ALLOWALL'})

    # Search API
    # Auto-load API and its subdirectories
    config.paths.add File.join('app/api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app','api', '**', '*.rb')]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.paths << Rails.root.join("public","lib")
    config.less.paths << Rails.root.join("assets","less")
    config.less.compress = true

    # Add environments to skylight
    config.skylight.environments += ["staging_unstable", "staging"]

    ActiveRecord::SessionStore::Session.table_name = 'rsessions'

    config.after_initialize do
      OpenID::Util.logger = Rails.logger
    end

    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
    )

    # Search API configuration
    config.paths.add File.join('app','api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    Raven.configure do |config|
      # DSN should be an ENV variable!
      config.dsn = ENV["SENTRY_DSN"] || 'https://0490297edae647b3bd935bdb4658da54:3d1a74cf68744c53b5e70484bece84d1@sentry.io/1410626'
      config.environments = %w(production)
      config.current_environment = ENV["COMPOSE_PROJECT_NAME"] || ENV["RAILS_ENV"] || %w(production)
    end

  end
end
