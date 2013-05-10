Innercircle::Application.routes.draw do

  resources :companies
  get "talent"=>"users#index"
  match 'join', to: 'users#new', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }
  match 'local_join', to: 'users#new', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }
  resources :users
  resources :profiles, only:[:edit, :update], constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }
  resources :password_resets

  match "/auth/linkedin/callback"=>"profiles#edit"
  match "auth/failure"=>"home#index"
  get "callback_session"=>"profiles#callback_session"
  get "signup"=>"companies#new"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  root :to => 'home#index'
end
