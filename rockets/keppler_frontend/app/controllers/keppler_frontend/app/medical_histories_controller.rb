require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::MedicalHistoriesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_cow
    before_action :attachments
    include ObjectQuery

    def index
      @medical_histories = @cow.medical_histories
    end

    def new
      @medical_history = KepplerCattle::MedicalHistory.new(user_id: current_user.id, cow_id: @cow&.id)
      # @location = KepplerCattle::Location.new(user_id: current_user.id, cow_id: @cow&.id, farm_id: @farm&.id)
      @corporal_conditions = @cow.species.corporal_conditions
      # @strategic_lots =  @cow.location&.farm&.strategic_lots
      # @strategic_lot = @cow.location&.strategic_lot
      # @typologies = @cow.possible_typologies
      @last_medical_history = @cow.medical_history
      # @farms = KepplerFarm::Farm.order(title: :asc)
    end

    def create
      @medical_history = KepplerCattle::MedicalHistory.new(medical_history_params)

      if @medical_history.save!
        flash[:notice] = 'Historia médica guardada'
        redirect_to farm_cow_medical_histories_path(@farm, @cow)
      else
        flash[:error] = 'No se pudo guardar la historia médica'
        render :new
      end
    end

    def create_multiple
    end

    private

    def set_cow
      @cow = KepplerCattle::Cow.find_by(id: params[:cow_id])
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
    def medical_history_params
      params.require(:medical_history).permit(
        KepplerCattle::MedicalHistory.attribute_names.map(&:to_sym)
      )
    end
  end
end
