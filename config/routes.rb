Letseatserver::Application.routes.draw do
  get "registrations/create"
  get "sessions/create"
  get "sessions/destroy"
  devise_for :users
  
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "/sign_in", :to => 'sessions#create'
        delete "/sign_out", :to => 'sessions#destroy'
        post "/register", :to => 'registrations#create'
      end
      post "/get_friends", :to => 'friends#getFriends'
      post "/get_non_friends", :to => 'friends#getNonFriends'
      post "/create_invitation", :to => 'invitations#create'
      post "/get_invitations", :to => 'invitations#get'
      post "/get_meals", :to => 'invitations#getMeals'
      post "/respond_no", :to => 'invitations#respondNo'
      post "/respond_yes", :to => 'invitations#respondYes'
      post "/get_invitation", :to => 'invitations#getInvitation'
      post "/cast_vote", :to => 'invitations#vote'
      post "/cast_unvote", :to => 'invitations#unvote'
    end
  end
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
