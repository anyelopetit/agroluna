require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::MilkWeightsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_cow
    before_action :set_milk_weight, except: %i[index new create destroy_multiple report]
    before_action :respond_to_formats
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index; end

    def report; end

    def show; end

    def new
      @milk_weight = KepplerReproduction::MilkWeight.new
    end

    def create
      @milk_weight = KepplerReproduction::MilkWeight.new(milk_weight_params)
      @cow.update!(milking: true, milking_date: milk_weight_params[:date])

      if @milk_weight.save!
        flash[:notice] = 'Pesaje de leche registrado'
        redirect_to farm_milk_index_path(@farm)
      else
        flash[:error] = 'Revisa los datos del formulario'
        redirect_to farm_milk_index_path(@farm)
      end
    end

    def edit; end

    def update
      if @milk_weight.update(milk_weight_params)
        redirect_to farm_milk_index_path(@farm)
      else
        redirect_to farm_milk_index_path(@farm)
      end
    end

    # DELETE /cattles/1
    def destroy
      @milk_weight.destroy
      redirect_to farm_milk_weights_path(@farm)
    end

    # def destroy_multiple
    #   KepplerReproduction::MilkWeight.destroy redefine_ids(params[:multiple_ids])
    #   redirect_to farm_cows_path(@farm)
    # end

    private

    def set_cow
      @cow = KepplerCattle::Cow.find_by(id: params[:cow_id])
    end

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

    def set_milk_weight
      @milk_weight = KepplerReproduction::MilkWeight.find(params[:id])
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

    # Only allow a trusted parameter "white list" through.
    def milk_weight_params
      params.require(:milk_weight).permit(
        KepplerReproduction::MilkWeight.attribute_names.map(&:to_sym)
      )
    end
  end

end
