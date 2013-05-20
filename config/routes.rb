Innercircle::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web, at: "/sidekiq"

  root :to => 'home#index'
  resources :users
  resources :companies
  resources :posts
  resources :password_resets
  resources :admin_invites

  constraints(Subdomain) do
    match 'join' => 'users#new'
    match 'local_join' => 'users#new'
  end

  constraints(NoSubdomain) do
    match 'join' => 'home#index'
    match 'local_join' => 'home#index'
  end

  get "dashboard" => "dashboard#index"
  get "/auth/linkedin/callback"=>"users#edit"
  get "auth/failure"=>"home#index"
  get "signup"=>"companies#new"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  get "for_companies"=>"static#for_companies"
end
