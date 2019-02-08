require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FrontendController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm, except: %i[root index]
    before_action :set_cow, only: %i[new_status create_status show_cattle edit_cattle update_cattle]
    before_action :cow_attributes, only: %i[new_cattle edit_cattle create_cattle]
    before_action :set_farms
    before_action :default_logo
    before_action :last_page
    
    include ObjectQuery

    def root
      if current_user
        redirect_to index_path
      else
        redirect_to main_app.new_user_session_path, locale: :es
      end
    end

    # begin index
    def index
      case current_user.role_ids[0]
      when 1
        if KepplerFarm::Farm.all.count > 0
          redirect_to app_farm_path(KepplerFarm::Farm.last)
        end
      else
        @assign = KepplerFarm::Assignment.where(user_id: current_user.id).first
        @farm = KepplerFarm::Farm.find_by(id: @assign.keppler_farm_farm_id) if @assign
        if @farm
          redirect_to app_farm_path(@farm)
        end
      end
    end
    # end index

    private

    def set_farm
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
    end

    def set_farms
      if current_user&.has_role?('keppler_admin')
        @farms = KepplerFarm::Farm.all
      else
        @assignments = KepplerFarm::Assignment.where(user_id: current_user&.id)
        @farms = KepplerFarm::Farm.where(id: @assignments&.map(&:keppler_farm_farm_id)) unless @assignments.count.zero?
      end
    end

    def default_logo
      @default_logo = 'http://www.stickpng.com/assets/images/5a1d2dc54ac6b00ff574e292.png'
    end

    # begin callback user_authenticate
    def user_authenticate
      redirect_to '/' unless user_signed_in?
    end
    # end callback user_authenticate

    def last_page
      session[:last_page] = request.env['HTTP_REFERER']
    end
  end
end
