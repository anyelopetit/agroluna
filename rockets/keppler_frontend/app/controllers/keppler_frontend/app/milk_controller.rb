require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::MilkController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :respond_to_formats
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @strategic_lots = @farm.strategic_lots.where.not(id: nil)
      @new_lot = @farm.strategic_lots.new
      @milk_lot = @farm.strategic_lots.find_by(id: @farm.milk_lot_id)
      @collection = @milk_lot.nil? ? @strategic_lots : (@strategic_lots - [@milk_lot])
      cows = (@milk_lot.blank? ? @farm.cows : @milk_lot.cows).where(gender: 'female')
      ids = cows.select { |c| c.typology&.reproductive }.pluck(:id)
      @cows = cows.where(id: ids)
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
      @cow = KepplerCattle::Cow.find(params[:id])
      insemination = @farm.inseminations.find(params[:status][:insemination_id])
      if params[:status][:insemination_quant].to_i > insemination.quantity.to_i
        flash[:error] = 'La cantidad de cartuchos no puede ser mayor a la existente'
      else
        if params[:status][:insemination_quant].to_i < 1
          flash[:error] = 'La cantidad de cartuchos debe ser superior a cero'
        else
          status = KepplerCattle::Status.new_status(params, {farm_id: @farm.id, cow_id: @cow.id, user: params[:status][:user_name]})
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
      @cow = KepplerCattle::Cow.find_by_id(
        params.dig(:status, :cow_id) || params[:id]
      )
      status = KepplerCattle::Status.new_status(params, {cow_id: @cow.id, farm_id: @farm.id})
      if status.save!
        flash[:notice] = 'Preñez registrada'
      else
        flash[:error] = 'No se pudo guardar la preñez'
      end
      redirect_back fallback_location: farm_milk_index_path(@farm)
    end

    def transfer_to_lot
      @cow = @farm.cows.find_by_id(params[:id])
      @strategic_lot = @farm.strategic_lots.find_by_id(params.dig(:cow, :location, :strategic_lot_id))
      if @cow && @strategic_lot
        new_location = @cow.locations.new(farm_id: @farm.id, strategic_lot_id: @strategic_lot.id, user_id: current_user.id)
        new_location.clean_other_cow_locations
        if new_location.save!
          flash[:notice] = "Serie #{@cow.serie_number} ha sido asignada a lote #{@strategic_lot.name}"
        else
          flash[:error] = 'No se pudo realizar la transferencia de lote'
        end
      else
        flash[:error] = "No se encontró #{('serie' if @cow.blank?) + ('ni' if @cow.blank? && @strategic_lot.blank?) + ('lote estratégico' if @strategic_lot.blank?)}"
      end
      redirect_back fallback_location: farm_milk_index_path(@farm)
    end

    def farm_milk_average
    end

    def milking_start
    end

    def milking_finish
    end

    def no_services_cows
    end

    def services_cows
    end

    def next_palpations
    end

    def pregnancies
    end

    def next_to_dry
    end

    def next_to_birth
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

    def respond_to_formats
      respond_to do |format|
        format.html
        format.csv #{ send_data KepplerCattle::Cow.all.to_csv, filename: "ganado.csv" }
        format.xls #{ send_data KepplerCattle::Cow.all.to_a.to_xls, filename: "ganado.xls" }
        format.json
        format.pdf { render pdf_options }
        format.js
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
