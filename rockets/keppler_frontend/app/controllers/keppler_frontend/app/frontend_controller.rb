require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FrontendController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    # layout 'layouts/keppler_frontend/app/layouts/application'
    layout 'layouts/templates/application'

    def root
      if current_user
        case current_user.role_ids[0]
        when 1
          redirect_to main_app.dashboard_path
        when 2
          redirect_to index_path
        end
      else
        redirect_to main_app.new_user_session_path, locale: :es
      end
    end

    # begin keppler
    def keppler
    end
    # end keppler

    # begin index
    def index
      redirect_to profile_land_path
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
