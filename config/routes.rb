Rails.application.routes.draw do
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/users' => 'users/registrations#destroy'
  end
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  get '/oauth2callback', to: 'auth#google_callback'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: [:show, :destroy] do
    resources :tweets do
      collection do
        post :export_to_google_sheets
      end
    end
  end
  root 'tweets#new'
end
