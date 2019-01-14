require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FrontendController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    # layout 'layouts/keppler_frontend/app/layouts/application'
    layout 'layouts/templates/application'
    before_action :set_farms

    def root
      if current_user
        case current_user.role_ids[0]
        when 1
          # redirect_to main_app.dashboard_path
          redirect_to index_path
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
      @assign = KepplerFarm::Assignment.where(user_id: current_user.id).first
      @farm = KepplerFarm::Farm.find(@assign.keppler_farm_farm_id) if @assign
      if @farm
        redirect_to profile_land_path(@farm)
      end
    end
    # end index

    # begin login
    def login
    end
    # end login

    # begin profile_land
    def profile_land
      @assign = KepplerFarm::Assignment.where(user_id: current_user.id).first
      @farm = KepplerFarm::Farm.find(@assign.keppler_farm_farm_id) if @assign
    end
    # end profile_land 

    private

    def set_farms
      @farms = KepplerFarm::Farm.all
    end

    # begin callback user_authenticate
    def user_authenticate
      redirect_to '/' unless user_signed_in?
    end
    # end callback user_authenticate
  end
end
