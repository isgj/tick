Rails.application.routes.draw do
  namespace :auth do
    post 'login' => 'user_token#create'
  end

  devise_for :users, skip: [:sessions, :registrations]#

  as :user do
    post 'auth/register' => 'auth/registrations#create'
  end

  namespace :api do
    namespace :v1 do
      resources :games, :only => [:index, :create] do
        patch :partecipate, on: :member
      end
    end
  end
end
