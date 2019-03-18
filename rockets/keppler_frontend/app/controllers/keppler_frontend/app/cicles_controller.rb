require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::CiclesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_season
    before_action :set_cicle, only: %i[show edit update destroy]
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index; end

    def new
      @cicle = KepplerReproduction::Cicle.new
    end

    def create
      @cicle = KepplerReproduction::Cicle.new(cicle_params)

      if @cicle.save
        redirect_to farm_season_path(@farm, @season)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render 'keppler_frontend/app/seasons/show'
      end
    end

    def edit; end

    def update
      if @cicle.update(cicle_params)
        redirect_to farm_season_path(@farm, @season)
      else
        render 'keppler_frontend/app/seasons/show'
      end
    end

    # DELETE /farms/1
    def destroy
      @cicle.destroy
      redirect_to farm_season_path(@farm, @season)
    end

    def destroy_multiple
      if farm_ids = redefine_ids('farm', params[:multiple_ids])
        flash[:notice] = 'Los ciclos han sido eliminados'
        KepplerReproduction::Cicle.destroy farm_ids
      else
        flash[:error] = 'No se pudieron eliminar'
      end
      redirect_to farm_cicles_path(@farm)
    end

    private

    def set_farm
      @farm = KepplerFarm::Farm.find(params[:farm_id])
    end

    def set_season
      @season = KepplerReproduction::Season.find_by(id: params[:season_id])
      @cows = @season.cows
    end

    def set_cicle
      @cicle = KepplerReproduction::Cicle.find_by(id: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def cicle_params
      params.require(:cicle).permit(
        KepplerReproduction::Cicle.attribute_names.map(&:to_sym)
      )
    end
  end
end
