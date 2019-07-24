require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::DeliveriesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_delivery, except: %i[index new create destroy_multiple]
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @deliveries = KepplerReproduction::Delivery.order(created_at: :desc)
    end

    def show; end

    def new
      @delivery = KepplerReproduction::Delivery.new
    end

    def create
      @delivery = KepplerReproduction::Delivery.new(delivery_params)

      if @delivery.save
        redirect_to farm_deliveries_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def edit; end

    def update
      if @delivery.update(delivery_params)
        redirect_to farm_deliveries_path(@farm)
      else
        render :edit
      end
    end

    # DELETE /cattles/1
    def destroy
      @delivery.destroy
      redirect_to farm_deliveries_path(@farm)
    end

    # def destroy_multiple
    #   KepplerReproduction::Delivery.destroy redefine_ids(params[:multiple_ids])
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

    def set_delivery
      @delivery = KepplerReproduction::Delivery.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def delivery_params
      params.require(:delivery).permit(
        KepplerReproduction::Delivery.attribute_names.map(&:to_sym)
      )
    end
  end

end
