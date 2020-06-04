require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::TasksController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_task, only: %i[update destroy]
    before_action :attachments
    before_action :respond_to_formats
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @tasks = @farm.tasks
      @new_task = KepplerFarm::Task.new
      @cows = @farm_cows.map { |c| [c.serie_number, c.id] }
      # respond_to_formats(@farm.tasks)
    end

    def create
      @task = KepplerFarm::Task.new(task_params)

      if @task.save!
        redirect_to farm_tasks_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @task.update(task_params)
        redirect_to farm_tasks_path(@farm)
      else
        render :index
      end
    end

    # DELETE /farms/1
    def destroy
      @task.destroy
      redirect_to action: :index, farm_id: @farm&.id
    end

    def destroy_multiple
      if farm_ids = redefine_ids('farm', params[:multiple_ids])
        flash[:notice] = 'Las notas han sido eliminados'
        KepplerFarm::Task.destroy farm_ids
      else
        flash[:error] = 'No se pudieron eliminar'
      end
      redirect_to farm_tasks_path(@farm)
    end

    private

    def set_task
      @task = KepplerFarm::Task.find_by(id: params[:id])
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
        format.csv { send_data KepplerFarm::Task.all.to_csv, filename: "lotes estratégicos.csv" }
        format.xls { send_data KepplerFarm::Task.all.to_a.to_xls, filename: "lotes estratégicos.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def task_params
      params.require(:task).permit(KepplerFarm::Task.column_names)
    end
  end
end
