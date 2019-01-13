require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FrontendController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    # layout 'layouts/keppler_frontend/app/layouts/application'
    layout 'layouts/templates/application'

    # begin keppler
    def keppler
    end
    # end keppler

    # begin index
    def index
    end
    # end index

    # begin login
    def login
    end
    # end login

    # begin profile_land
    def profile_land
    end
    # end profile_land 

    private
    # begin callback user_authenticate
    def user_authenticate
      redirect_to '/' unless user_signed_in?
    end
    # end callback user_authenticate
  end
end
