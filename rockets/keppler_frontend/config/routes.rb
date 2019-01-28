KepplerFrontend::Engine.routes.draw do
  
  # Root
  root to: 'app/frontend#root'
  get '/index', to: 'app/frontend#index', as: :index
  get '/login', to: 'app/frontend#login', as: :login

  #Farm
  get '/finca/:farm_id', to: 'app/frontend#farm', as: :app_farm

  # Farm strategic_lot
  get '/finca/:farm_id/lotes-estrategicos', to: 'app/strategic_lots#index', as: :app_farm_strategic_lots
  get '/finca/:farm_id/lote-estrategico/:strategic_lot_id', to: 'app/strategic_lots#show', as: :app_farm_strategic_lot
  get '/finca/:farm_id/editar-lote/:strategic_lot_id', to: 'app/strategic_lots#edit', as: :app_farm_strategic_lot_edit
  get '/finca/:farm_id/nuevo-lote', to: 'app/strategic_lots#new', as: :app_farm_strategic_lot_new
  post '/finca/:farm_id/lotes-estrategicos', to: 'app/strategic_lots#create', as: :app_farm_strategic_lot_create
  post '/finca/:farm_id/lote-estrategico/:strategic_lot_id/asignar-ganado', to: 'app/strategic_lots#assign_cattle', as: :app_farm_strategic_lot_assign_cattle
  patch '/finca/:farm_id/lote-estrategico/:strategic_lot_id', to: 'app/strategic_lots#update', as: :app_farm_strategic_lot_update
  delete '/finca/:farm_id/lote-estrategico/:strategic_lot_id', to: 'app/strategic_lots#destroy', as: :app_farm_strategic_lot_destroy
  delete '/finca/:farm_id/lote-estrategico/:strategic_lot_id/eliminar-ganado', to: 'app/strategic_lots#delete_assignment', as: :app_farm_strategic_lot_delete_assignment
  delete '/finca/:farm_id/lotes-estrategicos/destroy_multiple', to: 'app/strategic_lots#destroy_multiple', as: :app_farm_strategic_lot_destroy_multiple

  # Farm Cattle
  get '/finca/:farm_id/ganado', to: 'app/cattle#index', as: :app_farm_cows
  get '/finca/:farm_id/ganado/:cow_id', to: 'app/cattle#show', as: :app_farm_cow
  get '/finca/:farm_id/editar-ganado/:cow_id', to: 'app/cattle#edit', as: :app_farm_cow_edit
  get '/finca/:farm_id/nuevo-ganado', to: 'app/cattle#new', as: :app_farm_cow_new
  post '/finca/:farm_id/ganado', to: 'app/cattle#create', as: :app_farm_cow_create
  patch '/finca/:farm_id/ganado/:cow_id', to: 'app/cattle#update', as: :app_farm_cow_update
  delete '/finca/:farm_id/eliminar/:cow_id', to: 'app/cattle#destroy', as: :app_farm_cow_destroy

  # Farm Cattle Status
  get '/finca/:farm_id/ganado/:cow_id/nuevo-estado', to: 'app/status#new', as: :app_farm_cow_status_new
  post '/finca/:farm_id/ganado/:cow_id/crear-status', to: 'app/status#create', as: :app_farm_cow_statuses

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
