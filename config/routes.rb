Innercircle::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web, at: "/sidekiq"

  resources :users
  resources :companies
  resources :password_resets
  resources :admin_invites

  constraints(Subdomain) do
    match '/' => 'companies#show'
    match 'join' => 'users#new'
    match 'local_join' => 'users#new'
    get "new_from_provider" => "posts#new_from_provider"
    resources :posts, only:[:index, :update, :destroy]
  end

  constraints(NoSubdomain) do
    match 'join' => 'home#index'
    match 'local_join' => 'home#index'
  end

  root :to => 'home#index'
  get "dashboard" => "dashboard#index"
  get "/auth/linkedin/callback"=>"users#edit"
  get "auth/failure"=>"users#edit"
  get "signup"=>"companies#new"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  get "for_companies"=>"static#for_companies"
end
