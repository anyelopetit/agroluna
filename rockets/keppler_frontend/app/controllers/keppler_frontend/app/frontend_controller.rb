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
    before_action :index_variables
    before_action :attachments
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

    def listing
      @strategic_lots = KepplerFarm::StrategicLot.where(farm_id: @farm.id)
      @typologies = KepplerCattle::Typology.all
    end

    def show_cattle
      @statuses = @cow.statuses.order(id: :desc)
    end

    def new_cattle
      @cow = KepplerCattle::Cow.new
    end

    def create_cattle
      @cow = KepplerCattle::Cow.new(cow_params)

      if @cow.save && @cow.statuses.blank?
        # redirect(@cow, params)
        redirect_to app_farm_cow_status_new_path(@farm, @cow)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new_cattle
      end
    end

    def update_cattle
      if @cow.update(cow_params)
        if @cow.statuses.blank?
          redirect_to app_farm_cow_status_new_path(@farm, @cow)
        else 
          redirect_to app_farm_cow_path(@farm, @cow)
        end
      else
        render :edit
      end
    end

    def edit_cattle
    end

    def statuses
    end

    def new_status
      @status = KepplerCattle::Status.new
      @ubications = KepplerCattle::Status.ubications
      @corporal_conditions = KepplerCattle::Status.corporal_conditions
      @strategic_lots = KepplerFarm::StrategicLot.all
      @typologies = KepplerCattle::Typology.all
      @last_status = KepplerCattle::Status.last
      @farms = KepplerFarm::Farm.order(title: :asc)
    end

    def create_status
      @status = KepplerCattle::Status.new(status_params)

      if @status.save
        redirect_to app_farm_cow_path(@farm, @cow)
      else
        render :new
      end
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

    def set_cow
      @cow = KepplerCattle::Cow.find_by(id: params[:cow_id])
    end

    def cow_attributes
      @species = KepplerCattle::Cow.species
      @genders = KepplerCattle::Cow.genders
      @races   = KepplerCattle::Cow.races
      @posible_mothers = KepplerCattle::Cow.where(gender: 'female').map { |x| [x.serie_number, x.id] }
      @posible_fathers = KepplerCattle::Cow.where(gender: 'male').map { |x| [x.serie_number, x.id] }
    end

    def index_variables
      @q = KepplerCattle::Cow.ransack(params[:q])
      @cows = @q.result(distinct: true)
      @active_cows = @cows.page(@current_page).order(position: :desc).actives(@farm)
      @inactive_cows = @cows.page(@current_page).order(position: :desc).inactives(@farm)
      @total = @cows.size
      @attributes = KepplerCattle::Cow.index_attributes
    end

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

    def attachments
      @attachments = YAML.load_file(
        "#{Rails.root}/config/attachments.yml"
      )
    end

    # Only allow a trusted parameter "white list" through.
    def cow_params
      params.require(:cow).permit(
        :serie_number,
        :image,
        :short_name,
        :long_name,
        :species,
        :gender,
        :birthdate,
        :race,
        :coat_color,
        :nose_color,
        :tassel_color,
        :provenance, 
        :observations,
        :mother_id,
        :father_id
      )
    end

    # Only allow a trusted parameter "white list" through.
    def status_params
      params.require(:status).permit(
        :cow_id,
        :farm_id,
        :weight,
        :gained_weight,
        :years,
        :months,
        :days,
        :ubication,
        :corporal_condition,
        :reproductive,
        :defiant,
        :pregnant,
        :lactating,
        :breeding,
        :dead,
        :deathdate,
        :typology,
        :strategic_lot_id,
        :user_id,
        :comments
      )
    end
  end
end
