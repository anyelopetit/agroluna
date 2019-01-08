KepplerFarm::Engine.routes.draw do
  namespace :admin do
    scope :farm, as: :farm do
      resources :farms do
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
