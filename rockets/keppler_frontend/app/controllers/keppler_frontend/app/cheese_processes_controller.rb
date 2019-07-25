require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::CheeseProcessesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_cheese_process, except: %i[index new create destroy_multiple]
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @cheese_processes = KepplerReproduction::CheeseProcess.order(created_at: :desc)
    end

    def show; end

    def new
      @cheese_process = KepplerReproduction::CheeseProcess.new
    end

    def create
      @cheese_process = KepplerReproduction::CheeseProcess.new(cheese_process_params)

      if @cheese_process.save
        redirect_to farm_cheese_processes_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def edit; end

    def update
      if @cheese_process.update(cheese_process_params)
        redirect_to farm_cheese_processes_path(@farm)
      else
        render :edit
      end
    end

    # DELETE /cattles/1
    def destroy
      @cheese_process.destroy
      redirect_to farm_cheese_processes_path(@farm)
    end

    # def destroy_multiple
    #   KepplerReproduction::CheeseProcess.destroy redefine_ids(params[:multiple_ids])
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

    def set_cheese_process
      @cheese_process = KepplerReproduction::CheeseProcess.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def cheese_process_params
      params.require(:cheese_process).permit(
        KepplerReproduction::CheeseProcess.attribute_names.map(&:to_sym)
      )
    end
  end

end