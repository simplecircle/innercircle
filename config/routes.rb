Innercircle::Application.routes.draw do

  resources :companies
  get "talent"=>"users#index"
  match 'join', to: 'users#new', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }
  resources :users

  get "signup"=>"companies#new"
  get "login"=>"sessions#new"
  post "login"=>"sessions#create"
  get "logout"=>"sessions#destroy"
  get "confirmation"=>"users#confirmation"
  root :to => 'home#index'
end
