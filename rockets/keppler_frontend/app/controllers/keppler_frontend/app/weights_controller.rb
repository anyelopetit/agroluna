require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::WeightsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_cow
    before_action :index_variables
    before_action :attachments
    include ObjectQuery

    def index
    end

    def new
      @weight = KepplerCattle::Weight.new(user_id: current_user.id, cow_id: @cow&.id)
      # @location = KepplerCattle::Location.new(user_id: current_user.id, cow_id: @cow&.id, farm_id: @farm&.id)
      @corporal_conditions = @cow.species.corporal_conditions
      # @strategic_lots =  @cow.location&.farm&.strategic_lots
      # @strategic_lot = @cow.location&.strategic_lot
      # @typologies = @cow.possible_typologies
      @last_weight = @cow.weight
      # @farms = KepplerFarm::Farm.order(title: :asc)
    end

    def create
      @weight = KepplerCattle::Weight.new(weight_params)

      if @weight.save
        redirect_to change_typology_farm_cow_weights_path(@farm, @cow)
      else
        render :new
      end
    end

    def change_typology
    end

    def create_multiple
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
    def weight_params
      params.require(:weight).permit(
        KepplerCattle::Weight.attribute_names.map(&:to_sym)
      )
    end
  end
end
