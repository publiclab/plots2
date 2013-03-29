Plots2::Application.routes.draw do
  resources :rusers
  resources :users
  resources :user_sessions
  resources :images

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout
  match 'register' => 'users#create'
  match 'users/list' => 'users#list'
  match 'signup' => 'users#new'

  match 'wiki/:id' => 'wiki#show'
  match 'wiki/revisions/:id' => 'wiki#revisions'
  match 'wiki/edit/:id' => 'wiki#edit'
  match 'wiki/revisions/:id/:vid' => 'wiki#revision'
  match 'wiki' => 'wiki#index'
  match 'wiki/tags/:tags' => 'wiki#tags'

  match 'place/:id/feed' => 'place#feed'

  match 'place/:id' => 'legacy#place'
  match 'tool/:id' => 'legacy#tool'
  match 'people/:id' => 'legacy#people'
  match 'notes/:id' => 'legacy#notes'

  match 'research' => 'notes#index'
  match 'notes' => 'notes#index'
  match 'notes/author/:id' => 'notes#author'
  match 'notes/author/:author/:topic' => 'notes#author_topic'
  match 'notes/:author/:date/:id' => 'notes#show'

  match 'map' => 'search#map'
  match 'search' => 'search#advanced'
  match 'search/advanced' => 'search#advanced'
  match 'search/advanced/:id' => 'search#advanced'
  match 'search/:id' => 'search#index'
  match 'search/typeahead/:id' => 'search#typeahead'

  match 'tag/:id' => 'tag#show'
  match 'tag/suggested/:id' => 'tag#suggested'
  match 'tag/author/:id.json' => 'tag#author'
  match 'tag/create/:nid' => 'tag#create'
  match 'tag/delete/:nid/:tid' => 'tag#delete'

  match 'dashboard' => 'home#dashboard'
  match 'nearby' => 'home#nearby'
  match 'subscriptions' => 'home#subscriptions'
  match 'profile/:id' => 'users#profile'
  match 'feed/:author' => 'users#rss'

  match 'maps' => 'map#index'
  match 'map/:name/:date' => 'map#show'
  match 'archive' => 'map#index'
  match 'stats' => 'notes#stats'

  match 'spam' => 'admin#spam'
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  match 'post' => 'editor#post'
  match 'note/add' => 'legacy#note_add'

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
  root :to => 'home#front'

  # See how all your routes lay out with "rake routes"

  match ':id' => 'wiki#root'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

  match ':controller(/:action(/:id))(.:format)'

end
