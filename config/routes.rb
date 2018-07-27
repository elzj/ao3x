Rails.application.routes.draw do
  resources :works

  resources :drafts
  get '/drafts/new/:stage', to: 'drafts#new'
  post '/drafts/new/:stage', to: 'drafts#create'
  patch '/drafts/new/:stage', to: 'drafts#create'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
