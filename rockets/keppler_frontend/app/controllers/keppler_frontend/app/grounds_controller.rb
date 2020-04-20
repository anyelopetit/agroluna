require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::GroundsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_ground, only: %i[show edit update destroy mark_as_used]
    before_action :index_variables
    before_action :user_authenticate
    before_action :index_history, only: %i[index index_inactives]
    before_action :show_history, only: %i[show]
    before_action :respond_to_formats
    include ObjectQuery

    def index
      # respond_to_formats(@active_grounds)
    end

    def show
      # respond_to_formats(@ground)
    end

    def new
      @ground = KepplerFarm::Ground.new
    end

    def create
      @ground = KepplerFarm::Ground.new(ground_params)

      if @ground.save
        redirect_to action: :show, id: @ground.id
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @ground.update(ground_params)
        redirect_to action: :show, id: @ground.id
      else
        render :edit
      end
    end

    def edit
    end

    # DELETE /cattles/1
    def destroy
      @ground.destroy
      redirect_to farm_grounds_path(@farm)
    end

    def destroy_multiple
      KepplerFarm::Ground.destroy redefine_ids(params[:multiple_ids])
      redirect_to farm_grounds_path(@farm)
    end

    def mark_as_used
    end

    private

    def set_farm
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
    end

    def set_ground
      @ground = KepplerFarm::Ground.find_by(id: params[:id])
    end

    def index_variables
      @q = @farm.grounds.ransack(params[:q])
      @grounds = @q.result(distinct: true).order(:identifier)
      if request.format.symbol.eql?(:html)
        @grounds = @grounds.page(params[:page]).per(50)
      end
      @total = @grounds.size
      @attributes = KepplerFarm::Ground.index_attributes
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
        trackable_type: KepplerFarm::Ground.to_s
      ).or(
        @farm.activities.where(
          recipient_type: KepplerFarm::Ground.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def show_history
      @activities = @farm.activities.where(
        trackable_type: 'KepplerFarm::Ground',
        trackable_id: @ground&.id.to_s
      ).or(
        @farm.activities.where(
          recipient_type: 'KepplerFarm::Ground',
          recipient_id: @ground&.id.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def respond_to_formats
      respond_to do |format|
        format.html
        format.csv { send_data KepplerFarm::Ground.all.to_csv, filename: "pajuelas.csv" }
        format.xls { send_data KepplerFarm::Ground.all.to_a.to_xls, filename: "pajuelas.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def ground_params
      params.require(:ground).permit(
        KepplerFarm::Ground.attribute_names.map(&:to_sym)
      )
    end
  end
end
