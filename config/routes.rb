Rails.application.routes.draw do

  root 'members#index'

  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  resources :admin, only: [:index, :create, :destroy]
  
  resources :members, except: [:destroy] do
    collection { post :import_new }
    member     { post :tag }
    resources :payments, only: [:new, :create, :edit, :update, :destroy]
    resources :notes, only: [:new, :create, :edit, :update]
    resources :addresses, only: [:new, :create, :edit, :update]  
  end

  resources :addresses, only: [] do
    collection { get :duplicate_address_report }
  end

  resources :payments, only: [:index] do
    collection { post :import_new, :import_update }
  end

  resources :settings, only: [:index, :update]
  

end
