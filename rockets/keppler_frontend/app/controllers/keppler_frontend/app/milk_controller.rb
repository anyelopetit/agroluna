require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::MilkController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @strategic_lots = @farm.strategic_lots
      @new_lot = @farm.strategic_lots.new
      @milk_lot = @farm.strategic_lots.find_by(id: @farm.milk_lot_id)
    end

    def assign_lot
      @milk_lot = @farm.strategic_lots.find_by(id: params[:farm][:milk_lot_id])
      if @milk_lot
        @farm.update!(milk_lot_id: @milk_lot.id)
        flash[:notice] = "Lote estratégico ha sido asignado"
      else
        flash[:error] = "No se pudo asignar el lote estratégico"
      end
      redirect_back fallback_location: farm_milk_index_path
    end

    private

    def set_farm
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
    end

    def set_farms
      if current_user&.has_role?('keppler_admin')
        @farms = KepplerFarm::Farm.all
      else
        @assignments = KepplerFarm::Assignment.where(user_id: current_user&.id)
        @farms = KepplerFarm::Farm.where(id: @assignments&.map(&:keppler_farm_farm_id)) unless @assignments.size.zero?
      end
    end

    def milk_params
      params.require(:farm).permit(
        :milk_lot_id,
        :days_to_service,
        :days_to_pregnancy,
        :days_to_dry,
        :days_to_rest
      )
    end
  end

end
