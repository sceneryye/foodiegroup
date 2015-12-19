RailsOnForum::Application.routes.draw do

  

  get 'tags/create'

  get 'tags/update'

  get 'tags/destroy'

  namespace :admin do
  resources :reports
  get '/users_list', to: 'reports#users_list'
  get '/events_list', to: 'reports#events_list'
  get '/topics_list', to: 'reports#topics_list'
  get '/participants_list', to: 'reports#participants_list'
  get '/tags_list', to: 'reports#tags_list'
  end

  resource :votes, only: :create
  resources :chat
  resources :tags, only: [:create, :update, :destroy]

  mount Ckeditor::Engine => '/ckeditor'
  
  get    '/login',     to: 'sessions#new',     as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout
  resource  :session, only: :create

  resource :search

  resources :forums  do
    resources :topics, only: [:new, :create]
  end

  resources :topics, except: [:index, :new, :create]  do
    resources :comments, only: [:new, :create,:index]
  end 

  resources :events do 
    resources :participants do
       get   'confirm_paid'  ,on: :member
       post 'confirm_shiped', on: :member
       post 'wechat_pay', on: :member
    end
    resources :comments, only: [:new, :create,:index]
  end

  resources :groupbuys do 
    resources :participants do
       get   'confirm_paid'  ,on: :member
       post 'confirm_shiped', on: :member
       post 'wechat_pay', on: :member
    end
    resources :comments, only: [:new, :create,:index]
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
