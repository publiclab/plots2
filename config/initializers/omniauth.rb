#this file is used to store the variable needed for omniauth login and signup
Rails.application.config.middleware.use OmniAuth::Builder do
  #the provider is google_oauth2 and the app-key of google developers app is stored in OAUTH_GOOGLE_APP_KEY
  #the app-secret of google developers app is stored in variable OAUTH_GOOGLE_APP_SECRET
  provider :google_oauth2, ENV["OAUTH_GOOGLE_APP_KEY"],ENV["OAUTH_GOOGLE_APP_SECRET"] , skip_jwt: true
  #For provider github, app_id is stored in
  provider :github, ENV["OAUTH_GITHUB_APP_KEY"], ENV["OAUTH_GITHUB_APP_SECRET"], { scope: 'user:email' }
end
