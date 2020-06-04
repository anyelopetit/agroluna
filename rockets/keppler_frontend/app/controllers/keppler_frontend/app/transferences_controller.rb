require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::TransferencesController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_transference, only: %i[show edit update destroy]
    before_action :index_variables
    before_action :attachments
    before_action :index_history
    before_action :respond_to_formats
    include ObjectQuery

    def index
      @search_farms = @farms.map { |f| [f.title, f.id] }
      # respond_to_formats(KepplerCattle::Transference.all)
    end

    def show
      @cows = @transference.cows.order(:serie_number).page(params[:page])
      # respond_to_formats(@transference)
    end

    def new
      @cows = @farm_cows.order(:serie_number)
      @transference = @farm.transferences.new
      @farms = KepplerFarm::Farm.where.not(id: @farm&.id)
      # @reasons = KepplerCattle::Transference.reasons
    end

    def create
      @transference = KepplerCattle::Transference.new(transference_params)

      unless @transference.from_farm_id == @transference.to_farm_id
        if @transference.save!
          @transference.cows.map do |c|
            location = KepplerCattle::Location.new(
              c.location.as_json(except: :id)
            )
            location&.farm_id = @transference.to_farm_id
            location.save!
          end
          redirect_to farm_transferences_path(@farm)
        else
          flash[:error] = 'Revisa los datos del formulario'
          render :new
        end
      else
        flash[:error] = 'Error: Las fincas no pueden ser iguales'
        render :new
      end
    end

    # def update
    #   if @transference.update(transference_params)
    #     redirect_to farm_transferences_path(@farm)
    #   else
    #     render :edit
    #   end
    # end

    # def edit; end

    # # DELETE /cattles/1
    # def destroy
    #   @transference.destroy
    #   redirect_to farm_transferences_path(@farm)
    # end

    # def destroy_multiple
    #   KepplerCattle::Transference.destroy redefine_ids(params[:multiple_ids])
    #   redirect_to farm_transferences_path(@farm)
    # end

    private

    def set_transference
      @transference = KepplerCattle::Transference.find_by(id: params[:id])
    end

    def index_variables
      @q = KepplerCattle::Transference.ransack(params[:q])
      transferences = @q.result(distinct: true)
      @transferences = transferences.page(@current_page).where_from(@farm&.id).order(created_at: :desc)
      if params[:search]
        if params[:search][:from].to_i > 0
          @transferences = @transferences.where_from(params[:search][:from].to_i)
        end
        if params[:search][:to].to_i > 0
          @transferences = @transferences.where_to(params[:search][:to].to_i)
        end
      end
      @total = @transferences.size
      @attributes = KepplerCattle::Transference.index_attributes
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
    def transference_params
      params.require(:transference).permit(
        { cattle: [] }, :from_farm_id, :to_farm_id, :reason
      )
    end

    def index_history
      @activities = @farm.activities.where(
        trackable_type: KepplerCattle::Transference.to_s
      ).or(
        @farm.activities.where(
          recipient_type: KepplerCattle::Transference.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def respond_to_formats
      respond_to do |format|
        format.html
        format.csv # { send_data KepplerCattle::Transference.all.to_csv, filename: "transferencias.csv" }
        format.xls # { send_data KepplerCattle::Transference.all.to_a.to_xls, filename: "transferencias.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end
  end
end
