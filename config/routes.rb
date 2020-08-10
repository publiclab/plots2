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
  get 'verify/:token' => 'users#verify_email'
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
  get 'openid/:username(/:provider)' => 'openid#user_page' # optional provider for logging through provider at MK or SWB
  get 'openid/:username/xrds' => 'openid#user_xrds'
  get '/people/:username/identity(/:provider)' => 'legacy#openid_username' # optional provider for logging through provider at MK or SWB
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
  get 'subscribe/multiple/:type/:tagnames' => 'subscription#multiple_add'
  post 'subscribe/multiple/:type/:tagnames' => 'subscription#multiple_add'
  get 'subscribe/multiple/:type' => 'subscription#multiple_add'
  post 'subscribe/multiple/:type' => 'subscription#multiple_add'
  get 'wiki/stale' => 'wiki#stale'
  get 'wiki/new' => 'wiki#new'
  get 'wiki/replace/:id' => 'wiki#replace'
  post 'wiki/replace/:id' => 'wiki#replace'
  get 'wiki/popular' => 'wiki#popular'
  get 'wiki/liked' => 'wiki#liked'
  post 'wiki/create' => 'wiki#create'
  get 'wiki/diff' => 'wiki#diff'
  get 'wiki/:id' => 'wiki#show'
  get 'w/:id' => 'wiki#show'

  # these need precedence for tag listings
  get 'tag/graph.json' => 'tag#graph_data'
  get 'stats/graph' => 'tag#graph'
  get 'feed/tag/:tagname' => 'tag#rss'
  get ':node_type/tag/:id/author/:author' => 'tag#show_for_author'
  get 'tag/:id/author/:author' => 'tag#show_for_author'
  get ':node_type/tag(/:id)(/:start)(/:end)' => 'tag#show'
  get 'contributors/:id(/:start)(/:end)' => 'tag#show', node_type: 'contributors'
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

  #routes for simple-data-grapher
  get 'graph/fetch_graphobject' => 'csvfiles#fetch_graphobject'
  get 'graph' => 'csvfiles#new'
  post 'graph/object' => 'csvfiles#setter'
  post 'graph/note/graphobject' => 'csvfiles#add_graphobject'
  get 'graph/prev_file' => 'csvfiles#prev_files'
  get 'graph/data/:id' => 'csvfiles#user_files'
  get 'graph/file/:uid/:id' => 'csvfiles#delete'

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
  get "/wikis/author/:id" => "wiki#author"

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
  get "search/profiles/(:query)",  :to => "search#profiles"
  get "search/questions/(:query)", :to => "search#questions"
  get "search/places/(:query)",    :to => "search#places"
  get "search/tags/(:query)",      :to => "search#tags"
  get "search/notes/(:query)",     :to => "search#notes"
  get "search/content/(:query)",   :to => "search#new"
  get "search/all/(:query)",       :to => "search#all_content"
  get "search/",                   :to => "search#google"
  get "search/:query",             :to => "search#google_redirect"


  get 'widget/:id' => 'tag#widget'
  get 'blog' => 'tag#blog', :id => "blog"
  get 'blog/:id' => 'tag#blog'
  get 'blog2' => 'tag#blog2', :id => "blog2"
  get 'blog2/:id' => 'tag#blog2'
  get 'tags' => 'tag#index'
  get 'tags/related(/:id)' => 'tag#related'
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
  get 'tag/:id' => 'tag#show', :as => :tag
  get 'tag/:id/stats' => 'tag#stats', :as => :tag_stats
  get 'locations/form' => 'tag#location'
  get 'locations/modal' => 'tag#location_modal'
  get 'embed/grid/:tagname' => 'tag#gridsEmbed'
  get 'features/embed/:id' => 'features#embed'

  get 'rsvp/:id' => 'notes#rsvp'
  get 'feed/liked' => 'notes#liked_rss'

  get 'dashboard' => 'home#dashboard'
  get 'comments' => 'comment#index'
  get 'profile/comments/:id' => 'users#comments'
  get 'profile/comments/:id/tag/:tagname' => 'users#comments_by_tagname'
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


  get 'map' => 'map#map'
  get 'map/:id' => 'map#wiki'
  get 'maps' => redirect('/map/')
  get 'users/map' => 'users#map'
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
  get 'stats/notes' => 'stats#notes'
  get 'stats/notes/:start/:end' => 'stats#notes'
  get 'stats/wikis' => 'stats#wikis'
  get 'stats/wikis/:start/:end' => 'stats#wikis'
  get 'stats/comments' => 'stats#comments'
  get 'stats/comments/:start/:end' => 'stats#comments'
  get 'stats/maps' => 'stats#maps'
  get 'stats/maps/:start/:end' => 'stats#maps'
  get 'stats/users' => 'stats#users'
  get 'stats/users/:start/:end' => 'stats#users'
  get 'stats/questions' => 'stats#questions'
  get 'stats/questions/:start/:end' => 'stats#questions'
  get 'stats/answers' => 'stats#answers'
  get 'stats/answers/:start/:end' => 'stats#answers'
  get 'stats/tags' => 'stats#tags'
  get 'stats/node_tags' => 'stats#node_tags'
  get 'stats/node_tags/:start/:end' => 'stats#node_tags'
  get 'feed' => 'notes#rss'
  get 'rss.xml' => 'legacy#rss'

  get 'useremail' => 'admin#useremail'
  post 'useremail' => 'admin#useremail'
  get 'spam' => 'admin#spam'
  get 'spam/revisions' => 'admin#spam_revisions'
  get 'spam/comments' => 'admin#spam_comments'
  get 'spam/:type' => 'admin#spam'
  get 'spam/batch/:ids' => 'admin#batch'
  get 'spam2' => 'spam2#_spam'
  get 'spam2/comments' => 'spam2#_spam_comments'
  get 'spam2/revisions' => 'spam2#_spam_revisions'
  get 'spam2/flags' => 'spam2#_spam_flags'
  get 'spam2/users' => 'spam2#_spam_users'
  get 'spam2/comments/filter/:type/:pagination' => 'spam2#_spam_comments'
  get 'spam2/users/filter/:type/:pagination' => 'spam2#_spam_users'
  get 'spam2/flags/filter/:type/:pagination' => 'spam2#_spam_flags'
  get 'spam2/queue/filter/:tag' => 'spam2#_spam_queue'
  get 'spam2/filter/:type/:pagination' => 'spam2#_spam'
  get 'spam2/batch_spam/:ids' => 'batch#batch_spam'
  get 'spam2/batch_publish/:ids' => 'batch#batch_publish'
  get 'spam2/batch_delete/:ids' => 'batch#batch_delete'
  get 'spam2/batch_ban/:ids' => 'batch#batch_ban'
  get 'spam2/batch_unban/:ids' => 'batch#batch_unban'
  get 'spam2/batch_ban_user/:ids' => 'batch#batch_ban_user'
  get 'spam2/batch_unban_user/:ids' => 'batch#batch_unban_user'
  get 'spam2/batch_comment/:type/:ids' => 'batch#batch_comment'
  get 'admin/users' => 'admin#users'
  get 'admin/queue' => 'admin#queue'
  get 'ban/:id' => 'admin#ban'
  get 'unban/:id' => 'admin#unban'
  get 'moderate/revision/spam/:vid' => 'admin#mark_spam_revision'
  get 'moderate/revision/publish/:vid' => 'admin#publish_revision'
  get 'moderate/spam/:id' => 'admin#mark_spam'
  get 'moderate/publish/:id' => 'admin#publish'
  get 'moderate/flag_node/:id' => 'spam2#flag_node'
  get 'moderate/remove_flag_node/:id' => 'spam2#remove_flag_node'
  get 'moderate/flag_comment/:id' => 'spam2#flag_comment'
  get 'moderate/remove_flag_comment/:id' => 'spam2#remove_flag_comment'
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

  get 'post' => 'editor#post', :as => :editor_post
  post 'post' => 'editor#post', :as => :editor_path
  get 'post/choose' => 'editor#choose'
  get 'legacy' => 'editor#legacy'
  get 'editor' => 'editor#editor'
  get 'editor/rich/(:n)' => 'editor#rich'
  post 'images/create' => 'images#create'
  put 'note/add' => 'legacy#note_add'
  put 'page/add' => 'legacy#page_add'
  get 'sdg' => 'editor#tempfunc'

  get 'talk/:id' => 'talk#show'

  get 'questions/new' => 'questions#new'
  get 'questions' => 'questions#index'
  get 'questions_shadow' => 'questions#index_shadow'
  get 'question' => 'questions#index'
  get 'question_shadow' => 'questions#index_shadow'
  get 'questions/:author/:date/:id' => 'questions#show' 
  get 'questions/show/:id' => 'questions#show'
  get 'q/:id' => 'questions#shortlink'
  get 'questions/answered(/:tagnames)' => 'questions#answered'
  get 'questions/popular(/:tagnames)' => 'questions#popular'
  get 'questions/unanswered(/:tagnames)' => 'questions#unanswered'
  get 'questions/liked(/:tagnames)' => 'questions#liked'

  post 'users/test_digest_email' => 'users#test_digest_email'
  post 'admin/test_digest_email_spam' => 'admin#test_digest_email_spam'

  get 'comment/delete/:id' => 'comment#delete'
  get 'comment/update/:id' => 'comment#update'
  post 'comment/update/:id' => 'comment#update'
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

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

end
