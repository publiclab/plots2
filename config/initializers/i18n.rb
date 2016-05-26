# config/initializers/i18n.rb
if Rails.env.development? || Rails.env.test?
  I18n.exception_handler = lambda do |exception, locale, key, options|
    raise "Missing translation: #{key}"
  end
end