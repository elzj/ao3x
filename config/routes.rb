Rails.application.routes.draw do
  resources :works

  resources :drafts
  get '/drafts/new/:stage', to: 'drafts#new'
  post '/drafts/new/:stage', to: 'drafts#create'
  patch '/drafts/new/:stage', to: 'drafts#create'

  namespace :api, defaults: { format: :json } do
    resources :tags, only: [:index, :show] do
      collection { get :autocomplete }
    end
    resources :works
  end

  resources :tags do
    resources :works
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :users do
    resources :pseuds do
      resources :works, only: [:index]
    end
  end

  get '/r/*path', to: 'home#index', constraints: ->(request) do
    !request.xhr? && request.format.html?
  end

  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
