require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::InseminationsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_insemination, only: %i[show edit update destroy mark_as_used]
    before_action :insemination_attributes, only: %i[new edit create]
    before_action :index_variables
    before_action :user_authenticate
    before_action :index_history, only: %i[index index_inactives]
    before_action :show_history, only: %i[show]
    before_action :respond_to_formats
    include ObjectQuery

    def index
      # respond_to_formats(@active_inseminations)
    end

    def index_used
      # respond_to_formats(@inactive_inseminations)
    end

    def show
      # respond_to_formats(@insemination)
    end

    def new
      @insemination = KepplerCattle::Insemination.new
    end

    def create
      @insemination = KepplerCattle::Insemination.new(insemination_params)

      if @insemination.save
        redirect_to action: :show, id: @insemination.id
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @insemination.update(insemination_params)
        redirect_to action: :show, id: @insemination.id
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

    def mark_as_used
    end

    private

    def set_insemination
      @insemination = KepplerCattle::Insemination.find_by(id: params[:id])
    end

    def index_variables
      @q = KepplerCattle::Insemination.ransack(params[:q])
      @inseminations = @q.result(distinct: true)
      @active_inseminations = @inseminations
      @inactive_inseminations = @inseminations
      @total = @inseminations.size
      @attributes = KepplerCattle::Insemination.index_attributes
      @typologies = KepplerCattle::Typology.all
    end

    def insemination_attributes
      @species = KepplerCattle::Species.all
      @races   = KepplerCattle::Race.all
      @possible_mothers = KepplerCattle::Insemination.possible_mothers
      @possible_fathers = KepplerCattle::Insemination.possible_fathers
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

    def index_history
      @activities = @farm.activities.where(
        trackable_type: KepplerCattle::Insemination.to_s
      ).or(
        @farm.activities.where(
          recipient_type: KepplerCattle::Insemination.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def show_history
      @activities = @farm.activities.where(
        trackable_type: 'KepplerCattle::Insemination',
        trackable_id: @insemination&.id.to_s
      ).or(
        @farm.activities.where(
          recipient_type: 'KepplerCattle::Insemination',
          recipient_id: @insemination&.id.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def respond_to_formats
      respond_to do |format|
        format.html
        format.csv { send_data KepplerCattle::Insemination.all.to_csv, filename: "pajuelas.csv" }
        format.xls { send_data KepplerCattle::Insemination.all.to_a.to_xls, filename: "pajuelas.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def insemination_params
      params.require(:insemination).permit(
        :serie_number,
        :short_name,
        :farm_id,
        :species_id,
        :race_id,
        :typology_id,
        :mother_id,
        :father_id,
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
