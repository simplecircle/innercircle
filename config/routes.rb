Innercircle::Application.routes.draw do
  root :to => 'home#index'

  resources :companies
  resources :users
  resources :password_resets


  constraints(Subdomain) do
    match 'join' => 'users#new'
    match 'local_join' => 'users#new'
    resources :profiles, only:[:edit, :update]
  end

  constraints(NoSubdomain) do
    match 'join' => 'home#index'
    match 'local_join' => 'home#index'
  end

  get "profile" => "profiles#show"
  get "dashboard" => "dashboard#index"
  get "/auth/linkedin/callback"=>"profiles#edit"
  get "auth/failure"=>"home#index"
  get "callback_session"=>"profiles#callback_session"
  get "signup"=>"companies#new"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  get "for_companies"=>"static#for_companies"
end
