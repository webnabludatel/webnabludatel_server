Watcher::Application.routes.draw do
  root :to => "home#index"

  match "/about" => "high_voltage/pages#show", :id => "about"

  OmniAuth.config.path_prefix = "/users/auth"
  devise_for :users, controllers: { registrations: 'users/registrations' }, skip: :omniauth_callback
  devise_scope :user do
    namespace :users do
      match 'auth/:provider/callback' => 'authentications#create', as: :omniauth_callback,
            constraints: { provider: Regexp.union(User.omniauth_providers.map(&:to_s)) }
      delete 'auth/:id' => 'authentications#destroy', :as => :authentication
    end
  end

  post "/subscribe" => "splash_subscribers#create"

  resources :users, :only => [:show] do
    memeber do
      get :show_future
    end
  end
  match "/user/:id" => "users#show"

  resources :watcher_reports, :only => [:index]

  namespace :admin do
    resources :watcher_referrals, only: [] do
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
        resources :media_items, only: [:create, :update], shallow: true
      end
      resources :commissions, only: [] do
        collection do
          get :lookup
        end
      end
    end
  end
end
