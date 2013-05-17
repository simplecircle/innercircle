Innercircle::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web, at: "/sidekiq"

  resources :users
  resources :companies
  resources :posts
  resources :password_resets

  constraints(Subdomain) do
    match '/' => 'companies#show'
    match 'join' => 'users#new'
    match 'local_join' => 'users#new'
    resources :profiles, only:[:edit, :update]
  end

  root :to => 'home#index'
  constraints(NoSubdomain) do
    match 'join' => 'home#index'
    match 'local_join' => 'home#index'
  end

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
