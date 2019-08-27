KepplerCattle::Engine.routes.draw do
  namespace :admin do
    scope :cattle, as: :cattle do
      resources :statuses do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection
      end

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
        get 'races_js', action: :get_races, as: :get_races

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
        post '/filter_by_species', action: :filter_by_species, as: :filter_by_species, on: :collection

        resources :statuses  do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end

        resources :weights  do
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
