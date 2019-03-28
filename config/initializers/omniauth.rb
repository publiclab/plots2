#this file is used to store the variable needed for omniauth login and signup
Rails.application.config.middleware.use OmniAuth::Builder do
  #the provider is google_oauth2 and the app-key of google developers app is stored in OAUTH_GOOGLE_APP_KEY
  #the app-secret of google developers app is stored in variable OAUTH_GOOGLE_APP_SECRET
  provider :google_oauth2, ENV["OAUTH_GOOGLE_APP_KEY"],ENV["OAUTH_GOOGLE_APP_SECRET"] , skip_jwt: true
  #For provider github, app_id is stored in OAUTH_GITHUB_APP_KEY and app_secret in OAUTH_GITHUB_APP_SECRET
  provider :github, ENV["OAUTH_GITHUB_APP_KEY"], ENV["OAUTH_GITHUB_APP_SECRET"], { scope: 'user:email' }
  #For Facebook provider
  provider :facebook, ENV["OAUTH_FACEBOOK_APP_KEY"], ENV["OAUTH_FACEBOOK_APP_SECRET"]
  #For provider github, app_id is stored in OAUTH_TWITTER_APP_KEY and app_secret in OAUTH_TWITTER_APP_SECRET
  provider :twitter, ENV["OAUTH_TWITTER_APP_KEY"],  ENV["OAUTH_TWITTER_APP_SECRET"]
end
