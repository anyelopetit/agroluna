require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::InventoriesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_inventory, only: %i[show edit update destroy assign_cattle clean_filters]
    before_action :user_authenticate
    before_action :respond_to_formats
    include ObjectQuery

    def index
      @q = @farm.inventories.ransack(params[:q])
      @inventories = @q.result(distinct: true).page(params[:page]).per(50)
    end

    def show
      @q = @inventory.inventory_cows.ransack(params[:q])
      @inventory_cows = @q.result(distinct: true).page(params[:page]).per(50)
    end

    def new
      @inventory = @farm.inventories.new
    end

    def create
      @inventory = @farm.inventories.new(inventory_params)

      if @inventory.save
        redirect_to action: :show, id: @inventory.id
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @inventory.update(inventory_params)
        redirect_to action: :show, id: @inventory.id
      else
        render :edit
      end
    end

    def edit
    end

    # DELETE /cattles/1
    def destroy
      @inventory.destroy
      redirect_to farm_inventories_path(@farm)
    end

    def destroy_multiple
      @farm.inventories.destroy redefine_ids(params[:multiple_ids])
      redirect_to farm_inventories_path(@farm)
    end

    def assign_cattle
      if params[:cattle][:serie_number].blank?
        flash[:error] = 'Numero de serie no puede estar en blanco'
        return redirect_to action: :show, id: params[:inventory_id]
      end
      serie_number = params[:cattle][:serie_number]
      in_farm = params[:inventory][:inventory_cows_found]
      cow = KepplerCattle::Cow.find_by(serie_number: serie_number)

      inventory_cow = @inventory.inventory_cows.new(
        cow_id: cow&.id,
        serie_number: serie_number,
        found: cow.present?,
        in_farm: in_farm.to_i.zero? ? false : true
      )

      if inventory_cow.save!
        if inventory_cow.found
          flash[:notice] = "La serie #{serie_number} fue encontrada en el sistema"
        else
          flash[:error] = "No se pudo encontrar la serie #{serie_number} en el sistema"
        end
      else
        flash[:error] = "No se pudo guardar la serie #{serie_number} en este inventario"
      end
      redirect_to [@farm, @inventory]
    end

    def filter
      farm_id, inventory_id = [params[:farm_id], params[:inventory_id]]
      in_farm = params[:filter_by_farm].to_i
      in_system = params[:filter_by_system].to_i
      redirect_to "/finca/#{farm_id}/inventarios/#{inventory_id}?en-finca=#{in_farm}&en-sistema=#{in_system}"
    end

    def compare_inventories
    end

    def compare
      from = @farm.inventories.find(params[:compare][:from])
      to = @farm.inventories.find(params[:compare][:to])
      redirect_to action: :comparation, from: from, to: to
    end

    def comparation
      @from = @farm.inventories.find(params[:from])
      @to = @farm.inventories.find(params[:to])
      @q1 = @from.inventory_cows.where(in_farm: false).pluck(:serie_number)
      @q2 = @to.inventory_cows.where(in_farm: false).pluck(:serie_number)
      # @inventory_cows = @q.result(distinct: true).page(params[:page]).per(50)
      @inventory_cows = KepplerCattle::InventoryCow.where(serie_number: (@q1&@q2).uniq).select(:serie_number, :in_farm, :found).distinct
    end

    private

    def set_inventory
      @inventory = @farm.inventories.find_by(id: params[:inventory_id] || params[:id])
    end

    # begin callback user_authenticate
    def user_authenticate
      redirect_to '/' unless user_signed_in?
    end
    # end callback user_authenticate

    def respond_to_formats
      respond_to do |format|
        format.html
        format.csv { send_data @farm.inventories.all.to_csv, filename: "inventarios.csv" }
        format.xls { send_data @farm.inventories.all.to_a.to_xls, filename: "inventarios.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def inventory_params
      params.require(:inventory).permit(
        KepplerCattle::Inventory.attribute_names.map(&:to_sym)
      )
    end
  end
end
