Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["google_app_key"],ENV["google_app_secret"] , skip_jwt: true
  provider :facebook, ENV["APP_ID"],ENV["APP_SECRET"] , skip_jwt: true
end
