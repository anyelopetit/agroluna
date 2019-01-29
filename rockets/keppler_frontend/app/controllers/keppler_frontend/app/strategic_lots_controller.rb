require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::StrategicLotsController < App::FrontendController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_strategic_lot, only: %i[show edit update destroy]
    before_action :set_farm
    before_action :set_farms
    before_action :index_variables
    before_action :attachments
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @strategic_lots = @farm.strategic_lots
      @assign = KepplerCattle::Assignment.new
      @cows = @farm.cows.map { |c| [c.serie_number, c.id] }
      respond_to_formats(KepplerFarm::StrategicLot.all)
    end

    def show; end

    def new
      @strategic_lot = KepplerFarm::StrategicLot.new
    end

    def create
      @strategic_lot = KepplerFarm::StrategicLot.new(strategic_lot_params)

      if @strategic_lot.save
        redirect_to app_farm_strategic_lots_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @strategic_lot.update(strategic_lot_params)
        redirect_to app_farm_strategic_lots_path(@farm)
      else
        render :edit
      end
    end

    def edit; end

    # DELETE /farms/1
    def destroy
      @strategic_lot.destroy
      redirect_to app_farm_strategic_lots_path(@farm)
    end

    def destroy_multiple
      KepplerFarm::StrategicLot.destroy redefine_ids('farm', params[:multiple_ids])
      redirect_to app_farm_strategic_lots_path(@farm)
    end

    def assign_cattle
      @assignment = KepplerCattle::Assignment.new(
        strategic_lot_id: params[:strategic_lot_id],
        cow_id: params[:assignment][:cow_id]
      )

      if @assignment.validate_cow
        @assignment.save!
        flash[:notice] = "La serie #{@assignment.cow.serie_number} fue asignada satisfactoriamente"
      else
        flash[:error] = "Error: La serie #{@assignment.cow.serie_number} no fue asignada"
      end
      redirect_to app_farm_strategic_lots_path(@farm)
    end
      
    def delete_assignment
      @assignment = KepplerCattle::Assignment.find_by(
        strategic_lot_id: params[:strategic_lot_id],
        cow_id: params[:cow_id]
      )

      if @assignment.try(:exists?)
        if @assignment.destroy!
          flash[:notice] = 
            t('keppler.messages.cattle.deleted', cattle: @assignment.cow.serial_number) if @assignment.destroy!
        else
          flash[:error] = t('keppler.messages.cattle.not_deleted', cattle: @assignment.cow.serial_number)
        end
      else
        flash[:error] = t('keppler.messages.cattle.doesnt_exist', cattle: @assignment.cow.serial_number)
      end
      redirect_to action: :index, id: params[:farm_id]
    end

    private

    def set_strategic_lot
      @strategic_lot = KepplerFarm::StrategicLot.find(params[:strategic_lot_id])
    end

    def index_variables
      @q = KepplerFarm::StrategicLot.ransack(params[:q])
      set_strategic_lot = @q.result(distinct: true)
      @strategic_lots = set_strategic_lot.page(@current_page).order(position: :desc)
      @total = @strategic_lots.size
      @attributes = KepplerFarm::StrategicLot.index_attributes
    end

    def set_farm
      @farm = KepplerFarm::Farm.find(params[:farm_id])
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

    # Only allow a trusted parameter "white list" through.
    def strategic_lot_params
      params.require(:strategic_lot).permit(
        :name, :function, :description, :farm_id
      )
    end
  end
end
