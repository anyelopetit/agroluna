KepplerFarm::Engine.routes.draw do
  namespace :admin do
    scope :farm, as: :farm do
      resources :grounds do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection
      end

      resources :responsables do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection
      end


      resources :processes do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection
      end

      resources :farms do
        post '/sort', action: :sort, on: :collection
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/upload', action: 'upload', as: :upload
        get '/reload', action: :reload, on: :collection
        post '/assign_operator', action: :assign_operator
        delete '/delete_assignment/:user_id', action: :delete_assignment
        delete '/destroy_multiple', action: :destroy_multiple, on: :collection

        resources :photos do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          post '/toggle', action: 'toggle', as: 'toggle'
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
        end

        resources :strategic_lots do
          post '/sort', action: :sort, on: :collection
          get '(page/:page)', action: :index, on: :collection, as: ''
          get '/clone', action: 'clone'
          post '/upload', action: 'upload', as: :upload
          get '/reload', action: :reload, on: :collection
          delete '/destroy_multiple', action: :destroy_multiple, on: :collection
          post '/assign_cattle', action: :assign_cattle
          delete '/delete_assignment/:cow_id/', action: :delete_assignment
        end

      end

    end
  end
end
