require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::InseminationsController < App::FrontendController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_insemination, only: %i[show edit update destroy]
    before_action :insemination_attributes, only: %i[new edit create]
    before_action :index_variables
    before_action :user_authenticate
    include ObjectQuery

    def index
      respond_to_formats(KepplerCattle::Insemination.all)
    end

    def show
      respond_to_formats(@insemination)
    end

    def new
      @insemination = KepplerCattle::Insemination.new
    end

    def create
      @insemination = KepplerCattle::Insemination.new(insemination_params)

      if @insemination.save
        redirect_to action: :show
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @insemination.update(insemination_params)
        redirect_to action: :show
      else
        render :edit
      end
    end

    def edit
    end

    # DELETE /cattles/1
    def destroy
      @insemination.destroy
      redirect_to app_farm_inseminations_path(@farm)
    end

    def destroy_multiple
      KepplerCattle::Insemination.destroy redefine_ids(params[:multiple_ids])
      redirect_to app_farm_inseminations_path(@farm)
    end

    private

    def set_insemination
      @insemination = KepplerCattle::Insemination.find_by(id: params[:insemination_id])
    end

    def index_variables
      @q = KepplerCattle::Insemination.ransack(params[:q])
      @inseminations = @q.result(distinct: true)
      @active_inseminations = @inseminations#.where_no_used
      @inactive_inseminations = @inseminations#.where_used
      @total = @inseminations.size
      @attributes = KepplerCattle::Insemination.index_attributes
      @typologies = KepplerCattle::Typology.all
    end

    def insemination_attributes
      @species = KepplerCattle::Species.all
      @races   = KepplerCattle::Race.all
      @posible_mothers = KepplerCattle::Insemination.posible_mothers
      @posible_fathers = KepplerCattle::Insemination.posible_fathers
      @colors = KepplerCattle::Insemination.colors
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
    def insemination_params
      params.require(:insemination).permit(
        :serie_number,
        :short_name,
        :species_id,
        :race_id,
        :typology_id,
        :farm_id,
        :corporal_condition,
        :birthdate,
        :used,
        :coat_color,
        :nose_color,
        :tassel_color,
        :provenance,
        :observations
      )
    end
  end
end
