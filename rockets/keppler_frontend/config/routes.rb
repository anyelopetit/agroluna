KepplerFrontend::Engine.routes.draw do

  # Root
  root to: 'app/farms#root'

  get '/import-xls', to: 'app/farm#import_xls', as: :import_xls

  resources :farms, path: 'finca', controller: 'app/farms', path_names: { new: 'nuevo', edit: 'editar'} do
    collection do
      get 'landing'
      get 'login'
    end

    member do
      get 'species/:species_id/get_races', to: 'app/cattle#get_races', as: :get_races
      get 'historial', to: 'app/cattle#history', as: :history
    end

    resources :cows, path: 'ganado', controller: 'app/cattle', path_names: { new: 'nuevo', edit: 'editar'} do
      post 'activities', to: 'app/cattle#create_activities', as: :activities
      member do
        match 'buscar-ganado' => 'search', via: %i[get post], as: :search
        post :males
        post :wean, to: 'app/seasons#wean', as: :wean
        post :toggle_milking, as: :toggle_milking
        post :start_milking, as: :start_milking
        post :stop_milking, as: :stop_milking
        post :create_pregnancies, as: :create_pregnancies
        post :make_birth, as: :make_birth
      end
      collection do
        get 'inactivos', to: 'app/cattle#index_inactives', as: :inactives
        get :pagination
        # Weights
        get 'nuevos-pesajes/:multiple_ids', to: 'app/cattle#new_weights', as: :new_weights
        post '/create_weights/:multiple_ids', action: :create_weights, as: :create_weights
        get 'pesajes/:multiple_ids', to: 'app/cattle#show_weights', as: :weights

        # Procesos en lote
        get '/en-lote/nuevos-servicios(/:multiple_ids)', action: :new_services, as: :new_services
        post '/create_services/:multiple_ids', action: :create_services, as: :create_services

        get '/en-lote/nuevas-prenadas(/:multiple_ids)', action: :new_pregnancies, as: :new_pregnancies
        post '/create_pregnancies/:multiple_ids', action: :create_pregnancies, as: :create_pregnancies

        get '/en-lote/nuevos-partos(/:multiple_ids)', action: :new_births, as: :new_births
        post '/create_births/:multiple_ids', action: :create_births, as: :create_births

        post '/statuses', action: :statuses, as: :statuses
        post '/make_birth', action: :make_birth, as: :make_birth
        post '/make_abort', action: :make_abort, as: :make_abort
      end
      resources :weights, path: 'pesos', controller: 'app/weights', path_names: { new: 'nuevo', edit: 'editar'}, only: %i[new create] do
        get :change_typology, on: :collection
      end

      resources :milk_weights, path: 'pesajes-de-leche', controller: 'app/milk_weights' do
        get :report, as: :report, on: :collection
      end

      resources :medical_histories, path: 'historial-medico', controller: 'app/medical_histories', path_names: { new: 'nuevo', edit: 'editar' }
    end

    resources :strategic_lots, path: 'lotes-estrategicos', controller: 'app/strategic_lots', path_names: { new: 'nuevo', edit: 'editar'} do
      member do
        post :assign_cattle
        delete 'delete_assignment/:multiple_ids', to: 'app/strategic_lots#delete_assignment', as: :destroy_season_cows
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

    resources :inventories, path: 'inventarios', controller: 'app/inventories', path_names: { new: 'nuevo', edit: 'editar'} do
      patch :assign_cattle
      post :filter
      get 'comparar-inventarios', action: :compare_inventories, on: :collection, as: :compare_inventories
      post 'comparar', action: :compare, on: :collection, as: :compare
      get 'comparacion/:from/con/:to', action: :comparation, on: :collection, as: :comparation
    end

    resources :seasons, path: 'temporadas', controller: 'app/seasons', path_names: { new: 'nuevo', edit: 'editar'} do
      member do

        get 'asignar-ganado', action: :new_assign_cattle, as: :new_assign_cattle
        post :assign_cattle

        post 'lote-estrategico/:strategic_lot_id/assign_bulls', action: :assign_bulls, as: :assign_bulls
        delete 'lote-estrategico/:strategic_lot_id/destroy_season_cows/:multiple_ids', action: :destroy_season_cows, as: :destroy_season_cows

        get 'lote-estrategico/:strategic_lot_id/disponibles', action: :availables, as: :availables
        get 'lote-estrategico/:strategic_lot_id/celos', action: :zeals, as: :zeals
        get 'lote-estrategico/:strategic_lot_id/servicios', action: :services, as: :services
        get 'lote-estrategico/:strategic_lot_id/preñadas', action: :pregnants, as: :pregnants
        get 'lote-estrategico/:strategic_lot_id/paridas', action: :births, as: :births

        get 'lote-estrategico/:strategic_lot_id/new_services/:multiple_ids', action: :new_services, as: :new_services
        post 'lote-estrategico/:strategic_lot_id/create_services/:multiple_ids', action: :create_services, as: :create_services

        get 'lote-estrategico/:strategic_lot_id/new_pregnancies/:multiple_ids', action: :new_pregnancies, as: :new_pregnancies
        post 'lote-estrategico/:strategic_lot_id/create_pregnancies/:multiple_ids', action: :create_pregnancies, as: :create_pregnancies

        post 'lote-estrategico/:strategic_lot_id/statuses', action: :statuses, as: :statuses
        post '(lote-estrategico/:strategic_lot_id)/make_birth', action: :make_birth, as: :make_birth
        post '(lote-estrategico/:strategic_lot_id)/make_abort', action: :make_abort, as: :make_abort

        post :change_phase
        get :finish
        get :reopen

        # Reportes
        get :zeals_report, action: :zeals_report, as: :zeals_report
        get :services_report, action: :services_report, as: :services_report
        get :inseminated_cows, action: :inseminated_cows, as: :inseminated_cows
        get :next_palpation_report, action: :next_palpation_report, as: :next_palpation_report
        get :pregnants_report, action: :pregnants_report, as: :pregnants_report
        get :births_report, action: :births_report, as: :births_report
        get :next_births_report, action: :next_births_report, as: :next_births_report
        get :calfs_report, action: :calfs_report, as: :calfs_report
        get :twins_report, action: :twins_report, as: :twins_report
        get :abort_cows_report, action: :abort_cows_report, as: :abort_cows_report
        get :belly_report, action: :belly_report, as: :belly_report
        get :weans_report, action: :weans_report, as: :weans_report
        get :vet_efectivity_report, action: :vet_efectivity_report, as: :vet_efectivity_report
        get :efectivity_report, action: :efectivity_report, as: :efectivity_report
        get :bulls_report, action: :bulls_report, as: :bulls_report
      end

      collection do
        # Reportes
        get :inseminations_report, action: :inseminations_report, as: :inseminations_report
        get :reproduction_cows, action: :reproduction_cows, as: :reproduction_cows
        get :typologies_report, action: :typologies_report, as: :typologies_report
        get :inactive_cows_report, action: :inactive_cows_report, as: :inactive_cows_report
        get :analytic_weight_report, action: :analytic_weight_report, as: :analytic_weight_report
      end
    end

    resources :milk, path: 'lechera', controller: 'app/milk', only: %i[index] do
      collection do
        patch :assign_lot
        patch :edit_params
        post 'create_service/:id', action: :create_service, as: :create_service
        post 'create_pregnancy/:id', action: :create_pregnancy, as: :create_pregnancy
        patch 'transfer_to_lot/:id', action: :transfer_to_lot, as: :transfer_to_lot
        # get '/pesajes/:cow_id', action: :weights, as: :weights

        # Reports
        get 'promedio-leche', action: :farm_milk_average, as: :farm_milk_average # 10
        get 'inicio-ordeño', action: :milking_start, as: :milking_start
        get 'final-ordeño', action: :milking_finish, as: :milking_finish
        get 'series-sin-servicio', action: :no_services_cows, as: :no_services_cows
        get 'series-con-servicio', action: :services_cows, as: :services_cows
        get 'proximas-palpaciones', action: :next_palpations, as: :next_palpations
        get 'series-preñadas', action: :pregnancies, as: :pregnancies
        get 'proximas-a-secar', action: :next_to_dry, as: :next_to_dry
        get 'proximas-a-parir', action: :next_to_birth, as: :next_to_birth
      end
    end
    resources :cheese_types, path: 'tipos-de-queso', controller: 'app/cheese_types'
    resources :milk_tanks, path: 'tanques-de-leche', controller: 'app/milk_tanks'
    resources :deliveries, path: 'entregas', controller: 'app/deliveries'
    resources :cheese_processes, path: 'quesera', controller: 'app/cheese_processes'
    resources :tasks, path: 'tareas', controller: 'app/tasks', except: %i[new show edit]

    resources :grounds, path: 'campos', controller: 'app/grounds', path_names: { new: 'nuevo', edit: 'editar'} do
    end
  end

  # Admin

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
