Innercircle::Application.routes.draw do
  root :to => 'home#index'

  resources :companies
  resources :users
  resources :password_resets

  get "dashboard" => "dashboard#index"

  constraints(Subdomain) do
    match 'join' => 'users#new'
    match 'local_join' => 'users#new'
    resources :profiles, only:[:show, :update]
  end

  constraints(NoSubdomain) do
    match 'join' => 'home#index'
    match 'local_join' => 'home#index'
  end

  match "/auth/linkedin/callback" => "profiles#show"
  match "auth/failure" => "home#index"
  get "signup"=>"companies#new"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  
end
