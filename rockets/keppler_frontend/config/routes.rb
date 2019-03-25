KepplerFrontend::Engine.routes.draw do
  
  # Root
  root to: 'app/farms#root'

  get '/import-xls', to: 'app/farm#import_xls', as: :import_xls

  get 'species/:species_id/races', to: 'app/cattle#get_races', as: :get_races
  
  resources :farms, path: 'finca', controller: 'app/farms', path_names: { new: 'nuevo', edit: 'editar'} do
    collection do
      get 'landing'
      get 'login'
    end

    resources :cows, path: 'ganado', controller: 'app/cattle', path_names: { new: 'nuevo', edit: 'editar'} do
      member do
        match 'buscar-ganado' => 'search', via: %i[get post], as: :search
      end
      collection do
        get 'inactivos', to: 'app/cattle#index_inactives', as: :inactives
        get :pagination
        # Weights
        get 'nuevos-pesajes/:multiple_ids', to: 'app/cattle#new_weights', as: :new_weights
        post :create_weights
        get 'pesajes/:multiple_ids', to: 'app/cattle#show_weights', as: :weights
      end
      resources :weights, path: 'pesos', controller: 'app/weights', path_names: { new: 'nuevo', edit: 'editar'}, only: %i[new create]
    end

    resources :strategic_lots, path: 'lotes-estrategicos', controller: 'app/strategic_lots', path_names: { new: 'nuevo', edit: 'editar'} do
      member do
        post :assign_cattle
        delete :delete_assignment
      end
      collection do
        delete :destroy_multiple, params: { multiple_ids: [] }
        # Transfer
        get 'transferir/:multiple_ids', to: 'app/strategic_lots#transfer', as: :transfer
        post :create_transfer
        get 'transferidos/:multiple_ids', to: 'app/strategic_lots#transfered', as: :transfered
      end
    end

    resources :transferences, path: 'transferencias', controller: 'app/transferences', path_names: { new: 'nuevo', edit: 'editar'}, only: %w[index show new create]
    
    resources :inseminations, path: 'pajuelas', controller: 'app/inseminations', path_names: { new: 'nuevo', edit: 'editar'} do
      get :index_used, on: :collection, path: 'usadas'
      get :mark_as_used, on: :member, path: 'marcar-como-usada'
    end

    resources :seasons, path: 'temporadas', controller: 'app/seasons', path_names: { new: 'nuevo', edit: 'editar'} do
      resources :cicles, controller: 'app/cicles', only: %i[new create destroy]
    end
  end
  
  # Farm strategic_lot
  # get '/finca/:farm_id/lotes-estrategicos', to: 'app/strategic_lots#index', as: :farm_strategic_lots
  # get '/finca/:farm_id/lote-estrategico/:strategic_lot_id', to: 'app/strategic_lots#show', as: :farm_strategic_lot
  # get '/finca/:farm_id/editar-lote/:strategic_lot_id', to: 'app/strategic_lots#edit', as: :farm_strategic_lot_edit
  # get '/finca/:farm_id/nuevo-lote', to: 'app/strategic_lots#new', as: :farm_strategic_lot_new
  # post '/finca/:farm_id/lotes-estrategicos', to: 'app/strategic_lots#create', as: :farm_strategic_lot_create
  # post '/finca/:farm_id/lote-estrategico/:strategic_lot_id/asignar-ganado', to: 'app/strategic_lots#assign_cattle', as: :farm_strategic_lot_assign_cattle
  # delete '/finca/:farm_id/lote-estrategico/:strategic_lot_id/eliminar-ganado/(:multiple_ids)', to: 'app/strategic_lots#delete_assignment', as: :farm_strategic_lot_delete_assignment
  # patch '/finca/:farm_id/lote-estrategico/:strategic_lot_id', to: 'app/strategic_lots#update', as: :farm_strategic_lot_update
  # get '/finca/:farm_id/lote-estrategico/:strategic_lot_id/eliminar', to: 'app/strategic_lots#destroy', as: :farm_strategic_lot_destroy
  # delete '/finca/:farm_id/lotes-estrategicos/destroy_multiple', to: 'app/strategic_lots#destroy_multiple', as: :farm_strategic_lot_destroy_multiple
  
  # Farm Cattle
  # get '/finca/:farm_id/ganado', to: 'app/cattle#index', as: :farm_cattle
  # get '/finca/:farm_id/ganado-inactivo', to: 'app/cattle#index_inactives', as: :farm_cattle_inactive
  # get '/finca/:farm_id/ganado/:cow_id', to: 'app/cattle#show', as: :farm_cow
  # get '/finca/:farm_id/editar-ganado/:cow_id', to: 'app/cattle#edit', as: :farm_cow_edit
  # get '/finca/:farm_id/nuevo-ganado', to: 'app/cattle#new', as: :farm_cow_new
  # post '/finca/:farm_id/ganado', to: 'app/cattle#create', as: :farm_cow_create
  # patch '/finca/:farm_id/ganado/:cow_id', to: 'app/cattle#update', as: :farm_cow_update
  # delete '/finca/:farm_id/ganado/:cow_id/eliminar', to: 'app/cattle#destroy', as: :farm_cow_destroy
  # match '/finca/:farm_id/buscar-ganado' => 'app/cattle#search', via: [:get, :post], as: :cattle_search
  
  # Farm Cattle Status
  # get '/finca/:farm_id/ganado/:cow_id/nuevo-estado', to: 'app/status#new', as: :farm_cow_status_new
  # post '/finca/:farm_id/ganado/:cow_id/crear-status', to: 'app/status#create', as: :farm_cow_statuses

  # Farm Transferences
  # get '/finca/:farm_id/transferencias', to: 'app/transferences#index', as: :farm_transferences
  # get '/finca/:farm_id/transferencias/:transference_id', to: 'app/transferences#show', as: :farm_transference
  # # get '/finca/:farm_id/editar-transferencias/:transference_id', to: 'app/transferences#edit', as: :farm_transference_edit
  # get '/finca/:farm_id/nueva-transferencia', to: 'app/transferences#new', as: :farm_transference_new
  # post '/finca/:farm_id/transferencias', to: 'app/transferences#create', as: :farm_transference_create
  # # patch '/finca/:farm_id/transferencias/:transference_id', to: 'app/transferences#update', as: :farm_transference_update
  # # delete '/finca/:farm_id/transferencias/:transference_id/eliminar', to: 'app/transferences#destroy', as: :farm_transference_destroy

  # Farm Inseminations
  # get '/finca/:farm_id/pajuelas', to: 'app/inseminations#index', as: :farm_inseminations
  # get '/finca/:farm_id/pajuelas-usadas', to: 'app/inseminations#index_used', as: :farm_inseminations_used
  # get '/finca/:farm_id/pajuela/:insemination_id', to: 'app/inseminations#show', as: :farm_insemination
  # get '/finca/:farm_id/editar-pajuela/:insemination_id', to: 'app/inseminations#edit', as: :farm_insemination_edit
  # get '/finca/:farm_id/nueva-pajuela', to: 'app/inseminations#new', as: :farm_insemination_new
  # get '/finca/:farm_id/marcar-como-usada/:insemination_id', to: 'app/inseminations#mark_as_used', as: :farm_insemination_mark_as_used
  # post '/finca/:farm_id/pajuelas', to: 'app/inseminations#create', as: :farm_insemination_create
  # patch '/finca/:farm_id/pajuela/:insemination_id', to: 'app/inseminations#update', as: :farm_insemination_update
  # delete '/finca/:farm_id/pajuela/:insemination_id/eliminar', to: 'app/inseminations#destroy', as: :farm_insemination_destroy

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
