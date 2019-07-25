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

    def edit_params
      if @farm.update(milk_params)
        flash[:notice] = 'Parámetros actualizados'
      else
        flash[:error] = 'No se pudieron actualizar los parámetros'
      end
      redirect_back fallback_location: farm_milk_index_path
    end

    def create_service
      cow = KepplerCattle::Cow.find(params[:id])
      insemination = @farm.inseminations.find(params[:status][:insemination_id])
      if params[:status][:insemination_quant].to_i > insemination.quantity.to_i
        flash[:error] = 'La cantidad de cartuchos no puede ser mayor a la existente'
      else
        if params[:status][:insemination_quant].to_i < 1
          flash[:error] = 'La cantidad de cartuchos debe ser superior a cero'
        else
          status = KepplerCattle::Status.new_status(params, {farm_id: @farm.id, cow_id: cow.id, user: params[:status][:user_name]})
          unless insemination.quantity.to_i.zero?
            insemination.update(
              quantity: insemination.quantity.to_i - params[:status][:insemination_quant].to_i
            )
          end
          flash[:notice] = 'Servicio guardado' if status.save!
        end
      end
      redirect_back fallback_location: farm_milk_index_path(@farm)
    end

    def create_pregnancy
      cow = KepplerCattle::Cow.find_by_id(
        params.dig(:status, :cow_id) || params[:id]
      )
      status = KepplerCattle::Status.new_status(params, {cow_id: @cow.id, farm_id: @farm.id})
      if status.save!
        flash[:notice] = 'Servicio guardado'
      else
        flash[:error] = 'No se pudo guardar el servicio'
      end
      redirect_back fallback_location: farm_milk_index_path(@farm)
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
