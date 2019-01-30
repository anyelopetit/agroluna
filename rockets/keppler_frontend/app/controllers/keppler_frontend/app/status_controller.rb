require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::StatusController < App::FrontendController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_cow, only: %i[new create]
    before_action :set_farms
    before_action :index_variables
    before_action :attachments
    include ObjectQuery

    def index
    end

    def new
      @status = KepplerCattle::Status.new(farm_id: @farm.id, cow_id: @cow.id)
      @ubications = KepplerCattle::Status.ubications
      @corporal_conditions = KepplerCattle::Status.corporal_conditions
      @strategic_lots = KepplerFarm::StrategicLot.all
      @strategic_lot = @status.find_lot
      @typologies = KepplerCattle::Status.try("#{@cow.gender}_typologies".to_sym)
      @last_status = KepplerCattle::Status.last
      @farms = KepplerFarm::Farm.order(title: :asc)
    end

    def create
      @status = KepplerCattle::Status.new(status_params)

      if @status.save!
        redirect_to app_farm_cow_path(@farm, @cow)
      else
        render :new
      end
    end

    private

    def set_cow
      @cow = KepplerCattle::Cow.find_by(id: params[:cow_id])
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
