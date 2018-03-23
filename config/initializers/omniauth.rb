Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '199741036945-04g070p58u6m81bi4gq3l5r6dsfkfvap', 'XEcBrIHNHqTtko0lgBvWD7Cd', skip_jwt: true
end
