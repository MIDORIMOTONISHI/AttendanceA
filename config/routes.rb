Rails.application.routes.draw do
  resources :bases

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get '/edit_info', to: 'users#edit_info'
  
  # ログイン機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    collection { post :import }
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/confirm_one_month'
      get 'working'
      get 'edit_overwork_consent'
      patch 'update_overwork_consent'
      get 'attendances/edit_overwork_consent'
      patch 'attendances/update_overwork_consent'
      get 'attendances/edit_attendance_consent'
      patch 'attendances/update_attendance_consent'
      patch 'attendances/update_month_request'
      get 'attendances/edit_month_consent'
      patch 'attendances/update_month_consent'
      get 'attendances/attendance_log'
    end
    resources :attendances, only: :update do
      member do
        get 'edit_overwork_request'
        patch 'update_overwork_request'
      end
    end
  end
end
