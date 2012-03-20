Watcher::Application.routes.draw do

  root :to => "home#index"

  match "/about" => "high_voltage/pages#show", :id => "about"
  match "/press" => "high_voltage/pages#show", :id => "press"

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

  resources :reports, only: :index do
    collection do
      get :protocols
    end
  end
  get "/regions" => "reports#regions"

  resources :users, :only => [:show] do
    member do
      get :show_future
    end
  end
  match "/user/:id" => "users#show"

  resources :watcher_reports, :only => [:index]

  namespace :admin do
    resources :base, :only => :index
    resources :sos_messages, :only => [:index, :edit, :update]
    resources :watcher_referrals, :only => :index do
      member do
        post :approve
        post :reject
        post :problem
      end
    end
    resources :user_locations, :only => :index do
      member do
        post :approve
        post :reject
        post :problem
      end
    end

    resources :watcher_report_photos, :only => [:index, :update]
    resources :protocol_photos, :only => [:index, :update] do
      collection do
        get :approved
      end
    end

    resources :user_messages
  end

  namespace :api do
    namespace :v1 do
      resources :authentications, only: :create
      #resources :messages, only: [:create, :update] do
      #  resources :media_items, only: [:create, :update], shallow: true
      #end
      resources :commissions, only: [] do
        collection do
          get :lookup
        end
      end
    end
  end

  namespace :partners_api do
    namespace :v1 do
      resources :profiles, only: [:show, :index]
    end
  end
end
