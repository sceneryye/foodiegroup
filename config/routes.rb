RailsOnForum::Application.routes.draw do
  root 'groupbuys#index'
  resources :sites
  resources :vote_products
  resources :votings
  resources :wishlists
  post '/voting/vote_for_voting', to: 'votings#vote_for_voting'
  # get 'photos/create'

  # scope '/foodiegroup' do
  get 'groups/show'
  mount ChinaCity::Engine => '/china_city'
  get 'drag_drop', to: 'home#drag_drop', as: :drag_drop

  resources :user_addresses
  resources :logistics
  resources :photos, only: [:create, :destroy, :index, :new]

  get 'tags/create'

  post '/groupbuys/upload', to: 'groupbuys#upload'
  post '/groupbuys/destroy_pic', to: 'groupbuys#destroy_pic'
  get '/groupbuys/choose_or_new_groupbuy', to: 'groupbuys#choose_or_new_groupbuy', as: :choose_or_new_groupbuy
  get '/groupbuys/choose_from_groupbuys', to: 'groupbuys#choose_from_groupbuys', as: :choose_from_groupbuys
  get '/groupbuys/:id/new_from_groupbuy', to: 'groupbuys#new_from_groupbuy', as: :new_from_groupbuy

  get 'tags/update'

  get 'tags/destroy'

  post 'topics/more_comments', to: 'topics#more_comments'
  post 'groupbuys/more_comments', to: 'groupbuys#more_comments'
  post 'events/more_comments', to: 'events#more_comments'
  post 'cal_freightage', to: 'participants#cal_freightage'
  get 'downpayment_with_wechat', to: 'wishlists#downpayment_with_wechat', as: :downpayment_with_wechat
  post 'wechat_notify_url', to: 'participants#wechat_notify_url', as: :wechat_notify_url

  post 'wishlists/publish_wishlist', to: 'wishlists#publish_wishlist', as: :publish_wishlist

  post 'logistics/acquire_logistic_details', to: 'logistics#acquire_logistic_details', as: :acquire_logistic_details

  resources :admins do
    # post "downorder", :on=>:collection
    collection do
      get  :kols_list
      get :users_list
      post :downorder
      get :groupbuys_list
      get :topics_list
      get :participants_list
      get :tags_list
      post :set_online_offline
      get :hongbaos_list
      post :search_users
    end

    member do
       get :edit_user
       get :edit_groupbuy
       post :update_groupbuy
       get :send_hongbao
       post :update_user
    end
  end

  resource :votes, only: :create
  resources :chat
  resources :tags, only: [:create, :update, :destroy]

  # mount Ckeditor::Engine => '/ckeditor'

  get    '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout
  resource :session, only: :create

  resource :search

  resources :forums do
    resources :topics, only: [:new, :create]
  end

  resources :topics, except: [:index, :new, :create] do
    resources :comments, only: [:new, :create, :index]
  end

  resources :events do
    resources :participants, only: [:new, :create, :index]
    resources :comments, only: [:new, :create, :index]
  end

  resources :groupbuys do
    resources :participants, only: [:new, :create, :index]
    resources :comments, only: [:new, :create, :index]
  end

  resources :comments, only: [:edit, :update, :destroy]

  resources :participants, only: [:edit, :update, :destroy, :show] do
    get 'confirm_paid', on: :member
    post 'confirm_shiped', on: :member
  end
  get 'wechat_pay', to: 'participants#wechat_pay', as: :wechat_pay

  resources :users

  get '/users', to: 'users#index'

  get '/users/:id/my_shop_orders', to: 'users#my_shop_orders', as: :my_shop_orders
  get '/users/:id/my_hongbaos', to: 'users#my_hongbaos', as: :my_hongbaos
  get '/users/:id/my_groupbuys', to: 'users#my_groupbuys', as: :my_groupbuys
  get '/users/:id/my_events', to: 'users#my_events', as: :my_events
  get '/users/:id/my_topics', to: 'users#my_topics', as: :my_topics
  get '/users/:id/my_wishlists', to: 'users#my_wishlists', as: :my_wishlists
  get '/users/:id/contact_us', to: 'users#contact_us', as: :contact_us
  get '/users/:id/about_team', to: 'users#about_team', as: :about_team
  get '/users/:id/votings', to: 'users#votings', as: :my_votings
  get '/users/:id/wishlists_management', to: 'users#wishlists_management', as: :wishlists_management

  post '/users/set_user_mobile', to: 'users#set_user_mobile', as: :set_user_mobile

  resources :groups, only: [:show, :update]

  get '/register',    to: 'users#new',  as: :register
  get '/:id',         to: 'users#show', as: :profile
  get '/:id/edit', to: 'users#edit', as: :edit_profile
  get '/:id/user_info', to: 'users#user_info', as: :user_info
  get '/users/:id/my_orders', to: 'users#my_orders', as: :my_orders

  get '/sessions/auto_login', to: 'sessions#auto_login', as: :wx_auto_login
  get '/sessions/callback', to: 'sessions#callback', as: :wx_callback

  resource :home, only: [:index]

  get 'home/about_groupmall', to: 'home#about_groupmall', as: :about_groupmall

  # end
end
