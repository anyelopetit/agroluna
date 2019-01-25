KepplerFrontend::Engine.routes.draw do
  
  root to: 'app/frontend#root'
  get '/index', to: 'app/frontend#index', as: :index
  get '/login', to: 'app/frontend#login', as: :login
  get '/finca/:farm_id', to: 'app/frontend#farm', as: :app_farm
  get '/finca/:farm_id/listado', to: 'app/frontend#listing', as: :app_cattle_farm_cows
  get '/finca/:farm_id/ganado/:cow_id', to: 'app/frontend#show_cattle', as: :app_cattle_farm_cow
  get '/finca/:farm_id/editar-ganado/:cow_id', to: 'app/frontend#edit_cattle', as: :app_edit_cattle
  delete '/finca/:farm_id/eliminar/:cow_id', to: 'app/frontend#delete_cattle', as: :app_delete_cattle
  get '/finca/:farm_id/nuevo-ganado', to: 'app/frontend#new_cattle', as: :app_new_cattle
  post '/finca/:farm_id/listado', to: 'app/frontend#create_cattle', as: :app_create_cattle
  patch '/finca/:farm_id/ganado/:cow_id', to: 'app/frontend#update_cattle', as: :app_update_cattle
  get '/finca/:farm_id/ganado/:cow_id/nuevo-estado', to: 'app/frontend#new_status', as: :app_new_status
  post '/finca/:farm_id/ganado/:cow_id/crear-status', to: 'app/frontend#create_status', as: :app_create_status

  namespace :admin do
    scope :frontend, as: :frontend do
      resources :parameters do
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/sort', action: :sort, on: :collection
        post '/upload', action: 'upload', as: 'upload'
        get '/download', action: 'download', as: 'download'
        get(
          '/reload',
          action: :reload,
          on: :collection,
        )
        delete(
          '/destroy_multiple',
          action: :destroy_multiple,
          on: :collection,
          as: :destroy_multiple
        )
      end

      resources :functions do
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/sort', action: :sort, on: :collection
        post '/upload', action: 'upload', as: 'upload'
        get '/download', action: 'download', as: 'download'
        get '/editor', action: 'editor'
        post '/editor/save', action: 'editor_save'
        delete '/destroy_param/:param_id', action: :destroy_param, as: :destroy_param
        get(
          '/reload',
          action: :reload,
          on: :collection,
        )
        delete(
          '/destroy_multiple',
          action: :destroy_multiple,
          on: :collection,
          as: :destroy_multiple
        )
      end

      resources :callback_functions do
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/sort', action: :sort, on: :collection
        post '/upload', action: 'upload', as: 'upload'
        get '/download', action: 'download', as: 'download'
        get '/editor', action: 'editor'
        post '/editor/save', action: 'editor_save'
        get(
          '/reload',
          action: :reload,
          on: :collection,
        )
        delete(
          '/destroy_multiple',
          action: :destroy_multiple,
          on: :collection,
          as: :destroy_multiple
        )
      end

      resources :partials do
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/sort', action: :sort, on: :collection
        post '/upload', action: 'upload', as: 'upload'
        post '/editor/save', action: 'editor_save'
        get '/download', action: 'download', as: 'download'
        get(
          '/reload',
          action: :reload,
          on: :collection,
        )
        delete(
          '/destroy_multiple',
          action: :destroy_multiple,
          on: :collection,
          as: :destroy_multiple
        )
      end

      resources :themes do
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        post '/sort', action: :sort, on: :collection
        post '/upload', action: 'upload', as: 'upload'
        get '/download', action: 'download', as: 'download'
        get '/show_covers', action: 'show_covers', as: 'show_covers'
        get '/editor', action: 'editor'
        post '/editor/save', action: 'editor_save'
        get(
          '/reload',
          action: :reload,
          on: :collection,
        )
        delete(
          '/destroy_multiple',
          action: :destroy_multiple,
          on: :collection,
          as: :destroy_multiple
        )
      end

      get '/assets', to: 'multimedia#index', as: 'multimedia'
      post '/assets/upload', to: 'multimedia#upload', as: 'upload_multimedia'
      get '/assets/upload', to: 'multimedia#upload', as: 'show_upload_multimedia'
      delete '/assets/:search/:fileformat', to: 'multimedia#destroy', as: 'destroy_multimedia'
      get '/assets/:search/:fileformat', to: 'multimedia#destroy', as: 'show_destroy_multimedia'

      resources :views do
        delete '/destroy_callback/:view_callback_id', action: :destroy_callback, as: :destroy_callback
        get '(page/:page)', action: :index, on: :collection, as: ''
        get '/clone', action: 'clone'
        get '/editor', action: 'editor'
        post '/editor/save', action: 'editor_save'
        post '/live_editor/save', action: 'live_editor_save'
        post '/sort', action: :sort, on: :collection
        post '/select_theme_view/:theme_view', action: 'select_theme_view', as: :select_theme

        get(
          '/reload',
          action: :reload,
          on: :collection,
        )
        delete(
          '/destroy_multiple',
          action: :destroy_multiple,
          on: :collection,
          as: :destroy_multiple
        )
      end

    end
  end
end
