require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FrontendController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm, only: %i[show edit farm listing]
    before_action :cow_attributes, only: %i[new_cattle edit_cattle]
    before_action :set_farms
    before_action :default_logo
    before_action :index_variables
    include ObjectQuery

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
        redirect_to app_farm_path(@farm)
      end
    end
    # end index

    def listing
      cows_id = KepplerCattle::Cow.all.select { |x| x.statuses.last.farm_id.eql?(@farm.id) }.map(&:id)
      @cows = KepplerCattle::Cow.find(cows_id)
      @strategic_lots = KepplerFarm::StrategicLot.where(farm_id: @farm.id)
    end

    def show_cattle
    end

    def new_cattle
      @cow = KepplerCattle::Cow.new
    end

    def create_cattle
      @cow = Cow.new(cow_params)

      if @cow.save && @cow.statuses.blank?
        # redirect(@cow, params)
        redirect_to new_admin_cattle_cow_status_path(@cow)
      else
        render :new
      end
    end

    def edit_cattle
    end

    # begin login
    def login
    end
    # end login

    # begin farm
    def farm
    end
    # end farm 

    private

    def cow_attributes
      @species = Cow.species
      @genders = Cow.genders
      @races   = Cow.races
      @posible_mothers = Cow.where(gender: 'female').map { |x| [x.serie_number, x.id] }
      @posible_fathers = Cow.where(gender: 'male').map { |x| [x.serie_number, x.id] }
    end

    def index_variables
      @q = KepplerCattle::Cow.ransack(params[:q])
      @cows = @q.result(distinct: true)
      @objects = @cows.page(@current_page).order(position: :desc)
      @total = @cows.size
      @attributes = KepplerCattle::Cow.index_attributes
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_cow
      @cow = KepplerCattle::Cow.find(params[:id])
    end

    def cow_attributes
      @species = KepplerCattle::Cow.species
      @genders = KepplerCattle::Cow.genders
      @races   = KepplerCattle::Cow.races
      @posible_mothers = KepplerCattle::Cow.where(gender: 'female').map { |x| [x.serie_number, x.id] }
      @posible_fathers = KepplerCattle::Cow.where(gender: 'male').map { |x| [x.serie_number, x.id] }
    end

    def set_farm
      @farm = KepplerFarm::Farm.find(params[:farm_id])
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
  end
end
