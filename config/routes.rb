Watcher::Application.routes.draw do
  OmniAuth.config.path_prefix = "/users/auth"
  devise_for :users, controllers: { registrations: 'users/registrations' }, skip: :omniauth_callback
  devise_scope :user do
    namespace :users do
      match 'auth/:provider/callback' => 'authentications#create', as: :omniauth_callback,
            constraints: { provider: Regexp.union(User.omniauth_providers.map(&:to_s)) }
      delete 'auth/:id' => 'authentications#destroy', :as => :authentication
    end
  end

  match "/subscribe" => "splash_subscribers#create", via: :post

  root :to => "pages#show", :id => "app"

  # Pages (via high_voltage gem)
  match "/about" => "pages#show", :id => "about"
  match "/app" => "pages#show", :id => "app"
  match "/help" => "pages#show", :id => "help"

  namespace :admin do
    resources :watcher_referals, only: [] do
      collection do
        get :moderate
      end
      member do
        post :approve
        post :reject
        post :problem
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :authentications, only: :create
      resources :messages, only: [:create, :update] do
        resources :media_items, only: :create
      end
    end
  end
end
