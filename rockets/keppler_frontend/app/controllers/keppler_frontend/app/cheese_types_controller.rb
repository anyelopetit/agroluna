require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::CheeseTypesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_cheese_type, except: %i[index new create destroy_multiple]
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @cheese_types = KepplerReproduction::CheeseType.all
    end

    def show; end

    def new
      @cheese_type = KepplerReproduction::CheeseType.new
    end

    def create
      @cheese_type = KepplerReproduction::CheeseType.new(cheese_type_params)

      if @cheese_type.save
        redirect_to farm_cheese_types_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def edit; end

    def update
      if @cheese_type.update(cheese_type_params)
        redirect_to farm_cheese_types_path(@farm)
      else
        render :edit
      end
    end

    # DELETE /cattles/1
    def destroy
      @cheese_type.destroy
      redirect_to farm_cheese_types_path(@farm)
    end

    # def destroy_multiple
    #   KepplerReproduction::CheeseType.destroy redefine_ids(params[:multiple_ids])
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

    def set_cheese_type
      @cheese_type = KepplerReproduction::CheeseType.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def cheese_type_params
      params.require(:cheese_type).permit(
        KepplerReproduction::CheeseType.attribute_names.map(&:to_sym)
      )
    end
  end

end
