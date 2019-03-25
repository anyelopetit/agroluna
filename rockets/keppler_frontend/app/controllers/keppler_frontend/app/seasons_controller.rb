require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::SeasonsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_season, only: %i[show edit update destroy]
    before_action :set_farm
    before_action :set_farms
    before_action :index_variables
    before_action :attachments
    before_action :respond_to_formats
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
    end

    def show
      @cows = @season.cows.order(:serie_number)
      @cicle = KepplerReproduction::Cicle.new
      @strategic_lot = KepplerFarm::StrategicLot.new
      
    end

    def new
      @season = KepplerReproduction::Season.new
      @season_types = KepplerReproduction::Season.season_types
    end

    def create
      @season = KepplerReproduction::Season.new(season_params)

      if @season.save
        redirect_to farm_season_path(@farm, @season)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @season.update(season_params)
        redirect_to farm_season_path(@farm, @season)
      else
        render :edit
      end
    end

    def edit; end

    # DELETE /farms/1
    def destroy
      @season.destroy
      redirect_to action: :index, farm_id: @farm&.id
    end

    def destroy_multiple
      if farm_ids = redefine_ids('farm', params[:multiple_ids])
        flash[:notice] = 'Las temporadas han sido eliminados'
        KepplerReproduction::Season.destroy farm_ids
      else
        flash[:error] = 'No se pudieron eliminar'
      end
      redirect_to farm_seasons_path(@farm)
    end

    private

    def set_season
      @season = KepplerReproduction::Season.find_by(id: params[:id])
    end

    def index_variables
      @q = KepplerReproduction::Season.ransack(params[:q])
      set_season = @q.result(distinct: true)
      @seasons = set_season.page(@current_page).order(position: :desc)
      @total = @seasons.size
      @attributes = KepplerReproduction::Season.index_attributes
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

    def respond_to_formats
      respond_to do |format|
        format.html
        format.csv { send_data KepplerReproduction::Season.all.to_csv, filename: "lotes estratégicos.csv" }
        format.xls { send_data KepplerReproduction::Season.all.to_a.to_xls, filename: "lotes estratégicos.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def season_params
      params.require(:season).permit(
        KepplerReproduction::Season.attribute_names.map(&:to_sym)
      )
    end
  end
end
