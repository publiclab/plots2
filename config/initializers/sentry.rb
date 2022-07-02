
Sentry.init do |config|
# DSN should be an ENV variable!
config.dsn = ENV["SENTRY_DSN"] || 'https://0490297edae647b3bd935bdb4658da54@o239675.ingest.sentry.io/1410626'
config.breadcrumbs_logger = [:sentry_logger, :http_logger]

# To activate performance monitoring, set one of these options.
# We recommend adjusting the value in production:
config.traces_sample_rate = 0.5

config.environment = case ENV["COMPOSE_PROJECT_NAME"] 
  when 'plots_stable'
    'stable'
  when 'plots_unstable'
    'unstable'
else
  ENV["RAILS_ENV"]
end
config.enabled_environments = %w[production stable unstable]

# use Rails' parameter filter to sanitize the event payload:
# for Rails 6+:
# filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
# for Rails 5:
filter = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    filter.filter(event.to_hash)
  end
end