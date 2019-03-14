KepplerCattle::Engine.routes.draw do
  namespace :admin do
    scope :cattle, as: :cattle do
      resources :inseminations do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection
      end

      resources :species do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection

        resources :corporal_conditions do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end

        resources :weighing_days do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end

        resources :typologies do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end

        resources :races do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          # get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end
      end

      resources :transferences do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection
      end

      resources :cows do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection

        resources :statuses  do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end
      end

    end
  end
end
