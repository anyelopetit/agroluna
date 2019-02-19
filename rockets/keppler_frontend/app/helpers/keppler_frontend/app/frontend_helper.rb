module KepplerFrontend
  module App::FrontendHelper
    # begin navbar
    def navbar(params = {})
      render 'keppler_frontend/app/partials/navbar', params: params
    end
    # end navbar
    # begin devise_login
    def devise_login(hash = {})
      render 'keppler_frontend/app/partials/devise_login', params: params
    end
    # end devise_login
  end
end
