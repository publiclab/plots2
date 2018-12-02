require 'sidekiq/web'

Plots2::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount JasmineFixtureServer => '/spec/javascripts/fixtures' if defined?(Jasmine::Jquery::Rails::Engine)

  mount Sidekiq::Web => '/sidekiq'

  # Manually written API functions
  post 'comment/create/token/:id.:format', to: 'comment#create_by_token'

  post '/node/update/title' => 'notes#update_title'

  #Search RESTful endpoints
  #constraints(subdomain: 'api') do
  mount Srch::API => '/api'
  mount GrapeSwaggerRails::Engine => '/api/docs'
  #end

  resources :rusers
  resources :user_sessions
  resources :images
  resources :features

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # switch off subdomain matching when in development
  if Rails.env.test?
  # or to skip www:
    get "", to: 'wiki#subdomain', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' && r.subdomain != "i" && r.subdomain != "test" && r.subdomain != "new" && r.subdomain != "alpha"}
    get "*all", to: 'wiki#subdomain', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' && r.subdomain != "i" && r.subdomain != "test" && r.subdomain != "new" && r.subdomain != "alpha"}
  end

  get '/change_locale/:locale', to: 'settings#change_locale', as: :change_locale
  get 'assets' => "admin#assets"

  get 'login' => "user_sessions#new",      :as => :login
  get 'logout' => "user_sessions#destroy", :as => :logout
  get 'logoutRemotely' => 'user_sessions#logout_remotely'
  get 'users' => 'users#index'
  post 'register' => 'users#create'
  get 'reset' => 'users#reset'
  post 'reset' => 'users#reset'
  get 'reset/key/:key' => 'users#reset'
  get 'profiles', to: redirect('/people')
  get 'people' => 'users#list'
  get 'users/role/:id' => 'users#list'
  patch 'users/update' => 'users#update'
  get 'people/:id/following' => 'users#following', as: :following
  get 'people/:id/followers' => 'users#followers', as: :followers
  get 'people/:tagname' => 'users#list'
  get 'signup' => 'users#new'
  get 'home' => 'home#front'
  resources :relationships, only: [:create, :destroy]

  get '/wiki/:id/comments', to: 'wiki#comments'
  #resources :users

  get 'openid' => 'openid#index'
  post 'openid' => 'openid#index'
  # Try to get rails to accept params with periods in the keyname?
  # The following isn't right and it may be about param parsing rather than routing?
  # match 'openid' => 'openid#index', :constraints => { 'openid.mode' => /.*/ }
# try this; http://jystewart.net/2007/10/24/a-ruby-on-rails-openid-server/

  get 'openid/xrds' => 'openid#idp_xrds'
  get 'openid/decision' => 'openid#decision'
  post 'openid/decision' => 'openid#decision'
  get 'openid/resume' => 'openid#resume'
  get 'openid/:username' => 'openid#user_page'
  get 'openid/:username/xrds' => 'openid#user_xrds'
  get '/people/:username/identity' => 'legacy#openid_username'
  get '/user/:id/identity' => 'legacy#openid'
  post '/user/register' => 'legacy#register'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  get 'openid/service.wsdl' => 'openid#wsdl'

  get 'following/:type/:name' => 'subscription#following'
  delete 'unsubscribe/:type/:name' => 'subscription#delete'
  put 'subscribe/:type' => 'subscription#add'
  get 'subscribe/:type' => 'subscription#add'
  put 'subscribe/:type/:name' => 'subscription#add'
  get 'subscribe/:type/:name' => 'subscription#add'
  get 'subscriptions' => 'subscription#index'
  get 'subscriptions/digest' => 'subscription#digest'

  get 'wiki/stale' => 'wiki#stale'
  get 'wiki/new' => 'wiki#new'
  get 'wiki/replace/:id' => 'wiki#replace'
  get 'wiki/popular' => 'wiki#popular'
  get 'wiki/liked' => 'wiki#liked'
  post 'wiki/create' => 'wiki#create'
  get 'wiki/diff' => 'wiki#diff'
  get 'wiki/:id' => 'wiki#show'
  get 'w/:id' => 'wiki#show'

  # these need precedence for tag listings
  get 'feed/tag/:tagname' => 'tag#rss'
  get ':node_type/tag/:id/author/:author' => 'tag#show_for_author'
  get 'tag/:id/author/:author' => 'tag#show_for_author'
  get ':node_type/tag(/:id)(/:start)(/:end)' => 'tag#show'
  get 'contributors/:id(/:start)(/:end)' => 'tag#show', node_type: 'contributors'
  get 'contributors' => 'tag#contributors_index'
  get 'feed/tag/:tagname/author/:authorname' => 'tag#rss_for_tagged_with_author'
  get 'wiki/raw/:id' => 'wiki#raw'
  get 'wiki/revisions/:id' => 'wiki#revisions'
  get 'wiki/revert/:id' => 'wiki#revert'
  get 'wiki/edit/:id' => 'wiki#edit'
  post 'wiki/update/:id' => 'wiki#update'
  delete 'wiki/delete/:id' => 'wiki#delete'

  get 'wiki/revisions/:id/:vid' => 'wiki#revision'
  get 'wiki/:lang/:id' => 'wiki#show'
  get 'wiki/edit/:lang/:id' => 'wiki#edit'
  get 'wiki' => 'wiki#index'

  get 'place/:id/feed' => 'place#feed'
  get 'n/:id' => 'notes#shortlink'
  get 'i/:id' => 'images#shortlink'
  get 'p/:username' => 'users#shortlink'
  get 'notes' => 'notes#index'
  get 'notes/raw/:id' => 'notes#raw'
  get 'notes/popular' => 'notes#popular'
  get 'notes/liked' => 'notes#liked'
  get 'notes/image/:id' => 'notes#image'
  get 'notes/delete/:id' => 'notes#delete'
  post 'notes/delete/:id' => 'notes#delete'
  post 'notes/update/:id' => 'notes#update'
  post 'notes/create' => 'notes#create'
  get 'notes/publish_draft/:id' => 'notes#publish_draft'
  get 'notes/edit/:id' => 'notes#edit'
  get 'notes/show/:id/:token' => 'notes#show'

  get 'places' => 'notes#places'
  get 'tools' => 'notes#tools'
  get 'methods' => 'wiki#methods'
  get 'methods/:topic' => 'wiki#methods'
  get 'techniques' => 'wiki#techniques'

  get 'report/:id' => 'legacy#report'
  get 'node/:id' => 'legacy#node'
  get 'es/node/:id/view' => 'legacy#node'
  get 'place/:id' => 'legacy#place'
  get 'tool/:id' => 'legacy#tool'
  get 'people/:id' => 'legacy#people'
  get 'notes/recent' => 'notes#recent'
  get 'notes/:id' => 'legacy#notes'
  get 'sites/default/files/:filename.:format' => 'legacy#file'
  get 'sites/default/files/imagecache/:size/:filename.:format' => 'legacy#image'

  get 'research' => 'home#research'
  get 'notes' => 'legacy#notes'
  get 'notes/author/:id' => 'notes#author'
  get 'notes/author/:author/:topic' => 'notes#author_topic'
  get 'notes/show/:id' => 'notes#show'
  get 'notes/:author/:date/:id' => 'notes#show'
  get 'notes/feeds' => 'subscription#notes'

  # :id will be the node's id (like has no id)
  get 'likes' => 'like#index'
  get 'likes/node/:id/count' => 'like#show', :as => :like_count
  get 'likes/node/:id/query' => 'like#liked?', :as => :is_liked
  get 'likes/node/:id/create' => 'like#create', :as => :add_like
  get 'likes/node/:id/delete' => 'like#delete',  :as => :drop_like

  get "search/wikis/:query",       :to => "search#wikis"
  get "search/profiles/:query",    :to => "search#profiles"
  get "search/questions/:query",   :to => "search#questions"
  get "search/places/:query",      :to => "search#places"
  get "search/tags/:query",        :to => "search#tags"
  get "search/",                   :to => "search#new"
  get "search/notes/:query",       :to => "search#notes"
  get "search/:query",             :to => "search#all_content"


  get 'widget/:id' => 'tag#widget'
  get 'blog' => 'tag#blog', :id => "blog"
  get 'blog/:id' => 'tag#blog'
  get 'tags' => 'tag#index'
  get 'tags/:search' => 'tag#index'
  post 'tag/suggested/:id' => 'tag#suggested'
  get 'tag/parent' => 'tag#add_parent'
  get 'tag/author/:id.json' => 'tag#author'
  post 'tag/create/:nid' => 'tag#create'
  get 'tag/create/:nid' => 'tag#create'
  delete 'tag/delete/:nid/:tid' => 'tag#delete'
  get 'barnstar/give/:nid/:star' => 'tag#barnstar'
  get 'barnstar/give' => 'tag#barnstar'
  put 'tag/add_tag' => 'tag#add_tag'
  put 'tag/remove_tag/:id' => 'tag#remove_tag'
  put 'tag/remove_all_tags' => 'tag#remove_all_tags'
  get 'tag/:id' => 'tag#show'
  get 'locations/form' => 'tag#location'
  get 'locations/modal' => 'tag#location_modal'
  get 'embed/grid/:tagname' => 'tag#gridsEmbed'
  get 'features/embed/:id' => 'features#embed'

  get 'rsvp/:id' => 'notes#rsvp'
  get 'feed/liked' => 'notes#liked_rss'

  get 'dashboard' => 'home#dashboard'
  get 'comments' => 'comment#index'
  get 'profile/comments/:id' => 'users#comments'
  get 'nearby' => 'home#nearby'
  get 'profile/edit' => 'users#edit'
  post 'profile/photo' => 'users#photo'
  get 'profile/info/:id' => 'users#info', as: 'info'
  get 'profile' => 'users#profile'
  get 'profile/:id' => 'users#profile'
  get 'profile/:id/edit' => 'users#edit'
  get 'profile/:id/likes' => 'users#likes'
  get 'feed/:author' => 'users#rss'
  get '/settings' => 'users#settings'
  post '/save_settings' => 'users#save_settings'

  post 'profile/tags/create/:id' => 'user_tags#create'
  get 'profile/tags/create/:id' => 'user_tags#create'
  delete 'profile/tags/delete/:id' => 'user_tags#delete'
  get 'user_tags' => 'user_tags#index'
  get 'user_tags/:search' => 'user_tags#index'
  get 'groups' => 'user_tags#index'
  get 'groups/:search' => 'user_tags#index'


  get 'maps' => 'map#index'
  get 'users/map' => 'users#map'
  get 'map' => 'search#map'
  get 'maps/:id' => 'map#tag'
  get 'map/edit/:id' => 'map#edit'
  put 'map/update/:id' => 'map#update'
  delete 'map/delete/:id' => 'map#delete'
  get 'map/:name/:date' => 'map#show'
  get 'archive' => 'map#index'
  get 'stats/range' => 'stats#range'
  get 'stats' => 'stats#index'
  get 'stats/range/:start/:end' => 'stats#range'
  get 'stats/subscriptions' => 'stats#subscriptions'
  get 'feed' => 'notes#rss'
  get 'rss.xml' => 'legacy#rss'

  get 'useremail' => 'admin#useremail'
  post 'useremail' => 'admin#useremail'
  get 'spam' => 'admin#spam'
  get 'spam/revisions' => 'admin#spam_revisions'
  get 'spam/comments' => 'admin#spam_comments'
  get 'spam/:type' => 'admin#spam'
  get 'spam/batch/:ids' => 'admin#batch'
  get 'admin/users' => 'admin#users'
  get 'admin/queue' => 'admin#queue'
  get 'ban/:id' => 'admin#ban'
  get 'unban/:id' => 'admin#unban'
  get 'moderate/revision/spam/:vid' => 'admin#mark_spam_revision'
  get 'moderate/revision/publish/:vid' => 'admin#publish_revision'
  get 'moderate/spam/:id' => 'admin#mark_spam'
  get 'moderate/publish/:id' => 'admin#publish'
  get 'admin/promote/moderator/:id' => 'admin#promote_moderator'
  get 'admin/force/reset/:id' => 'admin#reset_user_password'
  get 'admin/demote/basic/:id' => 'admin#demote_basic'
  get 'admin/promote/admin/:id' => 'admin#promote_admin'
  get 'admin/migrate/:id' => 'admin#migrate'
  get 'admin/moderate/:id' => 'admin#moderate'
  get 'admin/unmoderate/:id' => 'admin#unmoderate'
  get 'admin/publish_comment/:id' => 'admin#publish_comment'
  get 'admin/mark_comment_spam/:id' => 'admin#mark_comment_spam'
  get 'smtp_test' => 'admin#smtp_test'

  get 'post' => 'editor#post'
  post 'post' => 'editor#post'
  get 'legacy' => 'editor#legacy'
  get 'editor' => 'editor#editor'
  get 'editor/rich/(:n)' => 'editor#rich'
  post 'images/create' => 'images#create'
  put 'note/add' => 'legacy#note_add'
  put 'page/add' => 'legacy#page_add'

  get 'talk/:id' => 'talk#show'

  get 'questions/new' => 'questions#new'
  get 'questions' => 'questions#index'
  get 'question' => 'questions#index'
  get 'questions/:author/:date/:id' => 'questions#show'
  get 'questions/show/:id' => 'questions#show'
  get 'q/:id' => 'questions#shortlink'
  get 'questions/answered(/:tagnames)' => 'questions#answered'
  get 'questions/popular(/:tagnames)' => 'questions#popular'
  get 'questions/unanswered(/:tagnames)' => 'questions#unanswered'
  get 'questions/liked(/:tagnames)' => 'questions#liked'

  post 'users/test_digest_email' => 'users#test_digest_email'

  post 'answers/create/:nid' => 'answers#create'
  get 'answers/create/:nid' => 'answers#create'
  get 'answers/update/:id' => 'answers#update'
  post 'answers/update/:id' => 'answers#update'
  put 'answers/update/:id' => 'answers#update'
  get 'answers/delete/:id' => 'answers#delete'
  delete 'answers/delete/:id' => 'answers#delete'
  get 'answers/accept/:id' => 'answers#accept'
  put 'answers/accept/:id' => 'answers#accept'

  get 'answer_like/show/:id' => 'answer_like#show'
  get 'answer_like/likes/:aid' => 'answer_like#likes'
  get 'questions/:username/:date/:topic/answer_like/likes/:aid' => 'answer_like#likes'


  get 'comment/answer_create/:aid' => 'comment#answer_create'
  get 'comment/delete/:id' => 'comment#delete'
  get 'comment/update/:id' => 'comment#update'
  post 'comment/update/:id' => 'comment#update'
  get 'comment/make_answer/:id' => 'comment#make_answer'
  post 'comment/make_answer/:id' => 'comment#make_answer'
  post '/comment/like' => 'comment#like_comment'
  get '/comment/create/:id' => 'comment#create'
  post 'comment/create/:id' => 'comment#create'

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

  get ':id' => 'wiki#root'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #handling omniauth callbacks
  match '/auth/:provider/callback', to: 'user_sessions#create', via: [:get, :post]
  get 'auth/failure', to: redirect('/')

end
