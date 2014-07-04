Plots2::Application.routes.draw do
  resources :rusers
  resources :user_sessions
  resources :images

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  #match '', to: 'blogs#show', constraints: {subdomain: /.+/}
  # or to skip www:
  match "", to: 'wiki#subdomain', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' && r.subdomain != "i" && r.subdomain != "test" }
  match "*all", to: 'wiki#subdomain', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' && r.subdomain != "i" && r.subdomain != "test" }

  match 'ioby' => "legacy#ioby"

  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout
  match 'register' => 'users#create'
  match 'reset' => 'users#reset'
  match 'reset/key/:key' => 'users#reset'
  match 'profiles' => 'users#list'
  match 'users/update' => 'users#update'
  match 'signup' => 'users#new'
  match 'home' => 'home#front'

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
  match 'wiki/popular' => 'wiki#popular'
  match 'wiki/liked' => 'wiki#liked'
  match 'wiki/create' => 'wiki#create'
  match 'wiki/:id' => 'wiki#show'
    # these need precedence for tag listings
    match 'feed/tag/:tagname' => 'tag#rss'
    match ':node_type/tag/:id' => 'tag#show'
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
  match 'notes/popular' => 'notes#popular'
  match 'notes/liked' => 'notes#liked'
  match 'notes/create' => 'notes#create'

  match 'places' => 'notes#places'
  match 'tools' => 'notes#tools'

  match 'report/:id' => 'legacy#report'
  match 'node/:id' => 'legacy#node'
  match 'es/node/:id/view' => 'legacy#node'
  match 'place/:id' => 'legacy#place'
  match 'tool/:id' => 'legacy#tool'
  match 'people/:id' => 'legacy#people'
  match 'notes/:id' => 'legacy#notes'
  match 'sites/default/files/:filename.:format' => 'legacy#file'
  match 'sites/default/files/imagecache/:size/:filename.:format' => 'legacy#image'

  match 'research' => 'notes#index'
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

  match 'search' => 'search#advanced'
  match 'search/advanced' => 'search#advanced'
  match 'search/advanced/:id' => 'search#advanced'
  match 'search/:id' => 'search#index'
  match 'search/typeahead/:id' => 'search#typeahead'

  match 'tag/:id' => 'tag#show'
  match 'widget/:id' => 'tag#widget'
  match 'blog' => 'tag#blog', :id => "blog"
  match 'blog/:id' => 'tag#blog'
  match 'contributors/:id' => 'tag#contributors'
  match 'contributors' => 'tag#contributors_index'
  match 'tag/suggested/:id' => 'tag#suggested'
  match 'tag/author/:id.json' => 'tag#author'
  match 'tag/create/:nid' => 'tag#create'
  match 'tag/delete/:nid/:tid' => 'tag#delete'
  match 'barnstar/give/:nid/:star' => 'tag#barnstar'
  match 'barnstar/give' => 'tag#barnstar'
  match 'rsvp/:id' => 'notes#rsvp'
  match 'feed/liked' => 'notes#liked_rss'

  match 'dashboard' => 'home#dashboard'
  match 'dashboard/comments' => 'home#comments'
  match 'profile/comments/:id' => 'users#comments'
  match 'nearby' => 'home#nearby'
  match 'profile/edit' => 'users#edit'
  match 'profile/:id' => 'users#profile'
  match 'profile/:id/edit' => 'users#edit'
  match 'profile/:id/likes' => 'users#likes'
  match 'feed/:author' => 'users#rss'

  match 'maps' => 'map#index'
  match 'map' => 'search#map'
  match 'maps/:id' => 'map#tag'
  match 'map/edit/:id' => 'map#edit'
  match 'map/update/:id' => 'map#update'
  match 'map/delete/:id' => 'map#delete'
  match 'map/:name/:date' => 'map#show'
  match 'archive' => 'map#index'
  match 'stats' => 'notes#stats'
  match 'stats/subscriptions' => 'subscription#stats'
  match 'feed' => 'notes#rss'
  match 'rss.xml' => 'legacy#rss'

  match 'useremail' => 'admin#useremail'
  match 'spam' => 'admin#spam'
  match 'spam/:type' => 'admin#spam'
  match 'spam/batch/:ids' => 'admin#batch'
  match 'admin/users' => 'admin#users'
  match 'ban/:id' => 'admin#ban'
  match 'unban/:id' => 'admin#unban'
  match 'moderate/spam/:id' => 'admin#mark_spam'
  match 'moderate/publish/:id' => 'admin#publish'
  match 'admin/promote/moderator/:id' => 'admin#promote_moderator'
  match 'admin/demote/basic/:id' => 'admin#demote_basic'
  match 'admin/promote/admin/:id' => 'admin#promote_admin'
  match 'admin/migrate/:id' => 'admin#migrate'
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  match 'post' => 'editor#post'
  match 'note/add' => 'legacy#note_add'
  match 'page/add' => 'legacy#page_add'

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
