require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::StrategicLotsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_strategic_lot, only: %i[show edit update destroy assign_cattle delete_assignment]
    before_action :index_variables
    before_action :attachments
    before_action :respond_to_formats
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
      @strategic_lots = @farm.strategic_lots
      @assign = KepplerCattle::Location.new
      @cows = @farm_cows.map { |c| [c.serie_number, c.id] }
      # respond_to_formats(@farm.strategic_lots)
    end

    def show
      @cows = @strategic_lot.cows.order(:serie_number).page(params[:page])
      @assign = KepplerCattle::Location.new
      # respond_to_formats(@strategic_lot)
    end

    def new
      @strategic_lot = KepplerFarm::StrategicLot.new
    end

    def create
      @strategic_lot = KepplerFarm::StrategicLot.new(strategic_lot_params)

      if @strategic_lot.save!
        redirect_to farm_strategic_lot_path(@farm, @strategic_lot)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @strategic_lot.update(strategic_lot_params)
        redirect_to farm_strategic_lots_path(@farm)
      else
        render :edit
      end
    end

    def edit; end

    # DELETE /farms/1
    def destroy
      @strategic_lot.destroy
      redirect_to action: :index, farm_id: @farm&.id
    end

    def destroy_multiple
      if farm_ids = redefine_ids('farm', params[:multiple_ids])
        flash[:notice] = 'Los lotes estratégicos han sido eliminados'
        KepplerFarm::StrategicLot.destroy farm_ids
      else
        flash[:error] = 'No se pudieron eliminar'
      end
      redirect_to farm_strategic_lots_path(@farm)
    end

    def assign_cattle
      if params[:strategic_lot].blank?
        flash[:error] = 'No se agregó ninguna serie al lote'
      else
        params[:strategic_lot][:cattle].each do |id|
          cow = KepplerCattle::Cow.find_by(id: id)
          if cow
            location = KepplerCattle::Location.new(
              user_id: current_user.id,
              farm_id: @farm.id,
              strategic_lot_id: params[:id],
              cow_id: id
            )
            location.clean_other_cow_locations
            location.save!
            flash[:notice] = "La series fueron asignada satisfactoriamente"
          end
        end
        flash[:notice] = 'Series agregadas al lote estratégico'
      end
      redirect_to action: :show
    end

    def delete_assignment
      if params[:multiple_ids].blank?
        flash[:error] = 'No se pudo remover ninguna serie del lote'
      else
        counter = 0
        params[:multiple_ids].remove("[", "]").split(',').each do |id|
          location = KepplerCattle::Location.find_by(
            strategic_lot_id: params[:id],
            cow_id: id
          )

          if location&.exists?
            counter += 1 if location.update(strategic_lot_id: nil)
          end
        end
      end
      if counter.zero?
        flash[:error] = 'No se removió ninguna serie'
      else
        flash[:notice] = "Se removieron #{counter} series del lote"
      end
      redirect_to action: :show, farm_id: @farm&.id, id: @strategic_lot.id
    end

    def transfer
      @cows = @farm_cows.where(id: params[:multiple_ids].split(','))
    end

    def create_transfer
      params.require(:weight).keys.each do |id|
        weight = KepplerCattle::Weight.new(multiple_cows_params(id).values[0])
        if weight.save!
          flash[:notice] = "Pesos fueron guardados correctamente"
        else
          flash[:error] = "Error al guardar los pesos"
        end
      end
      redirect_to weights_farm_cows_path(@farm, params[:weight].keys.join(','))
    end

    def transfered
      @cows = @farm_cows.where(id: params[:multiple_ids].split(',')).order(:serie_number)
    end

    private

    def set_strategic_lot
      @strategic_lot = KepplerFarm::StrategicLot.find_by(id: params[:id])
    end

    def index_variables
      @q = KepplerFarm::StrategicLot.ransack(params[:q])
      set_strategic_lot = @q.result(distinct: true)
      @strategic_lots = set_strategic_lot.page(@current_page).order(position: :desc)
      @total = @strategic_lots.size
      @attributes = KepplerFarm::StrategicLot.index_attributes
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
        format.csv { send_data KepplerFarm::StrategicLot.all.to_csv, filename: "lotes estratégicos.csv" }
        format.xls { send_data KepplerFarm::StrategicLot.all.to_a.to_xls, filename: "lotes estratégicos.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def strategic_lot_params
      params.require(:strategic_lot).permit(
        { cattle: [] }, :name, :function, :description, :farm_id
      )
    end
  end
end
