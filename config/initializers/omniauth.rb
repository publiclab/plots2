Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,'750385290438-5j2585masom95c3uplsvb9rnj1ojtrrv.apps.googleusercontent.com', 'NyV3fNN5hiCbMuW3ZsqgGwWj', {
      :skip_jwt => true,
      :scope => 'email, profile',
      :prompt => 'consent',
    }
    provider :facebook,'278812979315277','d3d980b60a21a51b42ea289956fdb488',  {

      :info_fields => 'email,name,gender'
    }
    provider :twitter, 'btK84ab8Fty6qOZ9zrxn152xu', 'EfqTWOeBnZVcFDkWpjUWFiTy7D2pLrsQiTXgbpA558vME1jpey'
end
