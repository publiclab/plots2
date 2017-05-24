Plots2::Application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount JasmineFixtureServer => '/spec/javascripts/fixtures' if defined?(Jasmine::Jquery::Rails::Engine)

  #Search RESTful endpoints
  #constraints(subdomain: 'api') do
  mount Srch::API => '/api'
  mount GrapeSwaggerRails::Engine => '/api/d1ocs'
  #end


  resources :rusers
  resources :user_sessions
  resources :images
  resources :features
  resources :searches

  get 'searches/test' => 'searches#test'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  #match '', to: 'blogs#show', constraints: {subdomain: /.+/}

  # switch off subdomain matching when in development
  if Rails.env.test?
  # or to skip www:
    match "", to: 'wiki#subdomain', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' && r.subdomain != "i" && r.subdomain != "test" && r.subdomain != "new" && r.subdomain != "alpha"}
    match "*all", to: 'wiki#subdomain', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' && r.subdomain != "i" && r.subdomain != "test" && r.subdomain != "new" && r.subdomain != "alpha"}
  end

  get '/change_locale/:locale', to: 'settings#change_locale', as: :change_locale
  match 'ioby' => "legacy#ioby"

  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout
  match 'register' => 'users#create'
  match 'reset' => 'users#reset'
  match 'reset/key/:key' => 'users#reset'
  get 'profiles', to: redirect('/people')
  get 'people' => 'users#list'
  get 'users/role/:id' => 'users#list'
  match 'users/update' => 'users#update'
  match 'people/:id/following' => 'users#following', as: :following
  match 'people/:id/followers' => 'users#followers', as: :followers
  match 'signup' => 'users#new'
  match 'home' => 'home#front'
  resources :relationships, only: [:create, :destroy]

  #resources :users

  match 'openid' => 'openid#index'
  # Try to get rails to accept params with periods in the keyname?
  # The following isn't right and it may be about param parsing rather than routing?
  # match 'openid' => 'openid#index', :constraints => { 'openid.mode' => /.*/ }
# try this; http://jystewart.net/2007/10/24/a-ruby-on-rails-openid-server/

  match 'openid/xrds' => 'openid#idp_xrds'
  match 'openid/decision' => 'openid#decision'
  match 'openid/resume' => 'openid#resume'
  match 'openid/:username' => 'openid#user_page'
  match 'openid/:username/xrds' => 'openid#user_xrds'
  match '/people/:username/identity' => 'legacy#openid_username'
  match '/user/:id/identity' => 'legacy#openid'
  match '/user/register' => 'legacy#register'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  match 'openid/service.wsdl' => 'openid#wsdl'

  match 'following/:type/:name' => 'subscription#following'
  match 'unsubscribe/:type/:name' => 'subscription#delete'
  match 'subscribe/:type' => 'subscription#add'
  match 'subscribe/:type/:name' => 'subscription#add'
  match 'subscriptions' => 'subscription#index'

  match 'wiki/new' => 'wiki#new'
  match 'wiki/replace/:id' => 'wiki#replace'
  match 'wiki/popular' => 'wiki#popular'
  match 'wiki/liked' => 'wiki#liked'
  match 'wiki/create' => 'wiki#create'
  match 'wiki/diff' => 'wiki#diff'
  match 'wiki/:id' => 'wiki#show'
    # these need precedence for tag listings
    match 'feed/tag/:tagname' => 'tag#rss'
    match ':node_type/tag(/:id)' => 'tag#show'
  match 'wiki/raw/:id' => 'wiki#raw'
  match 'wiki/revisions/:id' => 'wiki#revisions'
  match 'wiki/revert/:id' => 'wiki#revert'
  match 'wiki/edit/:id' => 'wiki#edit'
  match 'wiki/update/:id' => 'wiki#update'
  match 'wiki/delete/:id' => 'wiki#delete'
  match 'wiki/revisions/:id/:vid' => 'wiki#revision'
  match 'wiki/:lang/:id' => 'wiki#show'
  match 'wiki/edit/:lang/:id' => 'wiki#edit'
  match 'wiki' => 'wiki#index'

  match 'place/:id/feed' => 'place#feed'
  match 'n/:id' => 'notes#shortlink'
  match 'notes/raw/:id' => 'notes#raw'
  match 'notes/popular' => 'notes#popular'
  match 'notes/liked' => 'notes#liked'
  match 'notes/create' => 'notes#create'

  match 'places' => 'notes#places'
  match 'tools' => 'notes#tools'
  match 'methods' => 'notes#methods'
  match 'methods/:topic' => 'wiki#methods'
  match 'methods2' => 'wiki#methods'
  match 'techniques' => 'notes#techniques'

  match 'report/:id' => 'legacy#report'
  match 'node/:id' => 'legacy#node'
  match 'es/node/:id/view' => 'legacy#node'
  match 'place/:id' => 'legacy#place'
  match 'tool/:id' => 'legacy#tool'
  match 'people/:id' => 'legacy#people'
  match 'notes/:id' => 'legacy#notes'
  match 'sites/default/files/:filename.:format' => 'legacy#file'
  match 'sites/default/files/imagecache/:size/:filename.:format' => 'legacy#image'

  match 'research' => 'home#dashboard'
  match 'notes' => 'legacy#notes'
  match 'notes/author/:id' => 'notes#author'
  match 'notes/author/:author/:topic' => 'notes#author_topic'
  match 'notes/show/:id' => 'notes#show'
  match 'notes/:author/:date/:id' => 'notes#show'

  # :id will be the node's id (like has no id)
  match 'likes/node/:id/count' => 'like#show', :as => :like_count
  match 'likes/node/:id/query' => 'like#liked?', :as => :is_liked
  match 'likes/node/:id/create' => 'like#create', :as => :add_like
  match 'likes/node/:id/delete' => 'like#delete', :as => :drop_like

  match 'questions_search/:id' => 'questions_search#index'
  match 'questions_search/typeahead/:id' => 'questions_search#typeahead'

  #Search Pages
  match 'search/advanced/:id' => 'searches#new'
  match 'search/dynamic' => 'searches#dynamic'
  match 'search/dynamic/:id' => 'searches#dynamic'
  match 'search/typeahead/:id' => 'searches#typeahead'
  match 'search/questions/:id' => 'searches#questions'
  match 'search/questions_typeahead/:id' => 'searches#questions_typeahead'
  match 'search/:id' => 'searches#normal_search'
  match 'search/advanced' => 'searches#new'
  match 'search' => 'searches#new'

  # Question Search capability--temporary until combined with full Search Capabilities
  match 'questions_search/:id' => 'questions_search#index'
  match 'questions_search/typeahead/:id' => 'questions_search#typeahead'


  match 'widget/:id' => 'tag#widget'
  match 'blog' => 'tag#blog', :id => "blog"
  match 'blog/:id' => 'tag#blog'
  match 'contributors/:id' => 'tag#contributors'
  match 'contributors' => 'tag#contributors_index'
  match 'tags' => 'tag#index'
  match 'embed/grid/:tagname' => 'tag#gridsEmbed'
  match 'tag/suggested/:id' => 'tag#suggested'
  match 'tag/author/:id.json' => 'tag#author'
  match 'tag/create/:nid' => 'tag#create'
  match 'tag/delete/:nid/:tid' => 'tag#delete'
  match 'barnstar/give/:nid/:star' => 'tag#barnstar'
  match 'barnstar/give' => 'tag#barnstar'
  match 'tag/add_tag' => 'tag#add_tag'
  match 'tag/remove_tag/:id' => 'tag#remove_tag'
  match 'tag/remove_all_tags' => 'tag#remove_all_tags'
  match 'tag/:id' => 'tag#show'

  match 'locations/form' => 'tag#location'


  match 'rsvp/:id' => 'notes#rsvp'
  match 'feed/liked' => 'notes#liked_rss'

  match 'dashboard' => 'home#dashboard'
  match 'dashboard2' => 'home#dashboard2'
  match 'comments' => 'comment#index'
  match 'profile/comments/:id' => 'users#comments'
  match 'nearby' => 'home#nearby'
  match 'profile/edit' => 'users#edit'
  match 'profile/photo' => 'users#photo'
  match 'profile/info/:id' => 'users#info', as: 'info'
  match 'profile/:id' => 'users#profile'
  match 'profile/:id/edit' => 'users#edit'
  match 'profile/:id/likes' => 'users#likes'
  match 'feed/:author' => 'users#rss'

  match 'profile/suggested/:key/:value' => 'user_tags#suggested'
  match 'profile/tags/create/:id' => 'user_tags#create'
  match 'profile/tags/delete/:id' => 'user_tags#delete'
  match 'profile/location/create/:id' => 'location_tags#create'
  match 'profile/user/privacy' => 'users#privacy'


  match 'maps' => 'map#index'
  match 'users/map' => 'users#map'
  match 'map' => 'search#map'
  match 'maps/:id' => 'map#tag'
  match 'map/edit/:id' => 'map#edit'
  match 'map/update/:id' => 'map#update'
  match 'map/delete/:id' => 'map#delete'
  match 'map/:name/:date' => 'map#show'
  match 'archive' => 'map#index'
  match 'stats' => 'stats#index'
  match 'stats/range/:start/:end' => 'stats#range'
  match 'stats/subscriptions' => 'stats#subscription'
  match 'feed' => 'notes#rss'
  match 'rss.xml' => 'legacy#rss'

  match 'useremail' => 'admin#useremail'
  match 'spam' => 'admin#spam'
  match 'spam/revisions' => 'admin#spam_revisions'
  match 'spam/:type' => 'admin#spam'
  match 'spam/batch/:ids' => 'admin#batch'
  match 'admin/users' => 'admin#users'
  match 'ban/:id' => 'admin#ban'
  match 'unban/:id' => 'admin#unban'
  match 'moderate/revision/spam/:vid' => 'admin#mark_spam_revision'
  match 'moderate/revision/publish/:vid' => 'admin#publish_revision'
  match 'moderate/spam/:id' => 'admin#mark_spam'
  match 'moderate/publish/:id' => 'admin#publish'
  match 'admin/promote/moderator/:id' => 'admin#promote_moderator'
  match 'admin/demote/basic/:id' => 'admin#demote_basic'
  match 'admin/promote/admin/:id' => 'admin#promote_admin'
  match 'admin/migrate/:id' => 'admin#migrate'
  match 'admin/moderate/:id' => 'admin#moderate'
  match 'admin/unmoderate/:id' => 'admin#unmoderate'

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  match 'post' => 'editor#post'
  match 'legacy' => 'editor#legacy'
  match 'editor' => 'editor#editor'
  match 'images/create' => 'images#create'
  match 'note/add' => 'legacy#note_add'
  match 'page/add' => 'legacy#page_add'

  match 'talk/:id' => 'talk#show'

  match 'questions/new' => 'questions#new'
  match 'questions' => 'questions#index'
  match 'questions/:author/:date/:id' => 'questions#show'
  match 'questions/show/:id' => 'questions#show'
  match 'q/:id' => 'questions#shortlink'
  match 'questions/answered(/:tagnames)' => 'questions#answered'
  match 'questions/popular(/:tagnames)' => 'questions#popular'
  match 'questions/unanswered(/:tagnames)' => 'questions#unanswered'
  match 'questions/liked(/:tagnames)' => 'questions#liked'

  match 'answers/create/:nid' => 'answers#create'
  match 'answers/update/:id' => 'answers#update'
  match 'answers/delete/:id' => 'answers#delete'
  match 'answers/accept/:id' => 'answers#accept'

  match 'answer_like/show/:aid' => 'answer_like#show'
  match 'answer_like/likes/:aid' => 'answer_like#likes'

  match 'comment/answer_create/:aid' => 'comment#answer_create'

  #Swagger UI
  match 'web_api' => 'web_api#index'


  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#home'

  # See how all your routes lay out with "rake routes"

  match ':id' => 'wiki#root'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

  match ':controller(/:action(/:id))(.:format)'

end
