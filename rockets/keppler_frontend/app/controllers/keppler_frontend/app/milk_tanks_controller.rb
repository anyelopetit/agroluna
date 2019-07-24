require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::MilkTanksController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_milk_tank, except: %i[index new create destroy_multiple]
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @milk_tanks = KepplerReproduction::MilkTank.all
    end

    def show; end

    def new
      @milk_tank = KepplerReproduction::MilkTank.new
    end

    def create
      @milk_tank = KepplerReproduction::MilkTank.new(milk_tank_params)

      if @milk_tank.save
        redirect_to farm_milk_tanks_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def edit; end

    def update
      if @milk_tank.update(milk_tank_params)
        redirect_to farm_milk_tanks_path(@farm)
      else
        render :edit
      end
    end

    # DELETE /cattles/1
    def destroy
      @milk_tank.destroy
      redirect_to farm_milk_tanks_path(@farm)
    end

    # def destroy_multiple
    #   KepplerReproduction::MilkTank.destroy redefine_ids(params[:multiple_ids])
    #   redirect_to farm_cows_path(@farm)
    # end

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

    def set_milk_tank
      @milk_tank = KepplerReproduction::MilkTank.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def milk_tank_params
      params.require(:milk_tank).permit(
        KepplerReproduction::MilkTank.attribute_names.map(&:to_sym)
      )
    end
  end

end
