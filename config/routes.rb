Innercircle::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web, at: "/sidekiq"

  resources :users
  resources :companies
  resources :password_resets
  resources :admin_invites
  resources :linkedin, only:[:new, :create, :destroy]

  constraints(Subdomain) do
    get '/' => 'companies#show'
    get 'join' => 'users#new'
    get 'add-talent' => 'users#new'
    resources :posts, only:[:index, :update, :destroy]
  end

  constraints(NoSubdomain) do
    get 'join' => 'home#index'
  end

  root :to => 'home#index'
  get "newsletter" => "newsletter#index"
  get "send_password_reset" => "password_resets#create"
  get "dashboard" => "dashboard#index"
  get "/auth/linkedin/callback"=>"linkedin#create"
  get "auth/failure"=>"users#edit"
  get "signup"=>"users#new"
  get "signup/linkedin"=>"users#linkedin"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  get "for_companies"=>"newsletter#for_companies"
  get '/robots.txt' => 'static#robots'
  post 'relationships/:company_id'=>'relationships#create', as:'relationships'
  delete 'relationships/:company_id'=>'relationships#destroy', as:'relationship'
end