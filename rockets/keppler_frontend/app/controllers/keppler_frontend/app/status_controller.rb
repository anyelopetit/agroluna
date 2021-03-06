require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::StatusController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_cow, only: %i[new create]
    before_action :index_variables
    before_action :attachments
    include ObjectQuery

    def index
    end

    def new
      @weight = KepplerCattle::Weight.new(user_id: current_user.id, cow_id: @cow&.id)
      @location = KepplerCattle::Location.new(user_id: current_user.id, cow_id: @cow&.id, farm_id: @farm&.id)
      @corporal_conditions = @cow.species.corporal_conditions
      @strategic_lots =  @cow.location&.farm&.strategic_lots
      @strategic_lot = @cow.location&.strategic_lot
      @typologies = @cow.possible_typologies
      @last_status = @cow.weight
      @farms = KepplerFarm::Farm.order(title: :asc)
    end

    def create
      @status = KepplerCattle::Status.new(status_params)

      if @status.save!
        redirect_to farm_cow_path(@farm, @cow)
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
      @active_cows = @cows.page(@current_page).order(position: :desc).actives
      @inactive_cows = @cows.page(@current_page).order(position: :desc).inactives
      @total = @cows.size
      @attributes = KepplerCattle::Cow.index_attributes
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
        :typology_id,
        :strategic_lot_id,
        :user_id,
        :comments
      )
    end
  end
end
