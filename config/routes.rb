RailsOnForum::Application.routes.draw do
  #get 'photos/create'

  scope '/foodiegroup' do
    get 'groups/show'
    mount ChinaCity::Engine => '/china_city'

    resources :user_addresses
    resources :photos, only: [:create, :destroy, :index, :new]

    get 'tags/create'

    post '/groupbuys/upload', to: 'groupbuys#upload'
    post '/groupbuys/destroy_pic', to: 'groupbuys#destroy_pic'

    get 'tags/update'

    get 'tags/destroy'

    post 'topics/more_comments', to: 'topics#more_comments'
    post 'groupbuys/more_comments', to: 'groupbuys#more_comments'
    post 'events/more_comments', to: 'events#more_comments'

    namespace :admin do
    resources :reports
      get '/users_list', to: 'reports#users_list'
      get '/groupbuys_list', to: 'reports#groupbuys_list'
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
      resources :participants, only: [:new, :create,:index]
      resources :comments, only: [:new, :create,:index]
    end

    resources :groupbuys do 
      resources :participants, only: [:new, :create,:index]
      resources :comments, only: [:new, :create,:index]
    end

    resources :comments, only: [:edit, :update, :destroy]

    resources :participants, only: [:edit, :update, :destroy] do    
      get 'wechat_pay', on: :member
      get   'confirm_paid'  ,on: :member
      post 'confirm_shiped', on: :member
    end

    resources :users,   only: [:create, :update, :destroy] do
       resources :user_instetests
    end

    resources :groups, only: [:show, :update]

    get '/register',    to: 'users#new',  as: :register
    get '/:id',         to: 'users#show', as: :profile
    get '/:id/edit', to: 'users#edit', as: :edit_profile
    post '/wechat_notify_url', to: 'participants#wechat_notify_url'

    resource :home, only: [:index]

    root 'home#index'
  end
end
