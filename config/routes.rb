Plots2::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  match 'wiki/:id' => 'wiki#show'
  match 'wiki/revisions/:id' => 'wiki#revisions'
  match 'wiki/revisions/:id/:vid' => 'wiki#revision'
  match 'wiki' => 'wiki#index'
  match 'place/:id' => 'wiki#place'
  match 'tool/:id' => 'wiki#tool'
  match 'wiki/tags/:tags' => 'wiki#tags'
  match 'research' => 'notes#index'
  match 'notes/author/:id' => 'notes#author'
  match 'notes/author/:author/:topic' => 'notes#author_topic'
  match 'notes/:author/:date/:id' => 'notes#show'
  match 'search/:id' => 'search#index'
  match 'search/typeahead/:id' => 'search#typeahead'
  match 'tag/:id' => 'tag#tag'
  match 'dashboard' => 'home#dashboard'
  match 'profile/:id' => 'home#profile'
  match 'people/:id' => 'home#people'
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  match 'post' => 'home#post'

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
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  match ':id' => 'wiki#root'


end
