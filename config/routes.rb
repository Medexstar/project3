Rails.application.routes.draw do
  
  root :to => redirect('weather/locations')
  get 'weather/locations' => 'locations#index'
  get 'weather/data/:location_id/:date' => 'measurements#show_location_id', constraints: {location_id: /[A-Z\s_]*/, date: /\d{,2}-\d{,2}-\d{4}/}
  get 'weather/data/:post_code/:date' => 'measurements#show_postcode', constraints: {post_code: /\d+/}, date: /\d{,2}-\d{,2}-\d{4}/
  get 'weather/prediction/:lat/:long/:period' => 'prediction#show_lat_long', constraints: {lat: /-?\d+.\d*/, long: /-?\d+.\d*/, period: /\d{,2}0/}
  get 'weather/prediction/:postcode/:period' => 'prediction#show_postcode', constraints: {postcode: /\d+/, period: /\d{,2}0/}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
