RailsOnForum::Application.routes.draw do

  

  namespace :admin do
  resources :reports
  end

  resource :votes, only: :create

  mount Ckeditor::Engine => '/ckeditor'
  
  get    '/login',     to: 'sessions#new',     as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout
  resource  :session, only: :create

  resource :search

  resources :forums  do
    resources :topics, only: [:new, :create]
  end

  resources :topics, except: [:index, :new, :create]  do
    resources :comments, only: [:new, :create,:destroy]
  end

 

  resources :events do 
    resources :participants do
       get   'confirm_paid'  ,on: :member
       post 'wechat_pay', on: :member
    end
    resources :comments, only: [:new, :create]
  end

  resources :comments, only: [:edit, :update, :destroy]

  resources :users,   only: [:create, :update, :destroy] do
     resources :user_instetests
  end

  get '/register',    to: 'users#new',  as: :register
  get '/:id',         to: 'users#show', as: :profile
  get '/:id/edit', to: 'users#edit', as: :edit_profile
  post '/wechat_notify_url', to: 'participants#wechat_notify_url'


  root 'forums#index'
end
