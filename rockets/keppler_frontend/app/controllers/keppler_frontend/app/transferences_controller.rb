require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::TransferencesController < App::FrontendController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_transference, only: %i[show edit update destroy]
    before_action :set_farms
    before_action :index_variables
    before_action :attachments
    include ObjectQuery

    def index
      @search_farms = @farms.map { |f| [f.title, f.id] }
      respond_to_formats(KepplerCattle::Transference.all)
    end

    def show
      @cows = @transference.cows
      respond_to_formats(@transference)
    end

    def new
      @cows = @farm.cows.actives.map { |c| [c.serie_number, c.id] }
      @transference = KepplerCattle::Transference.new
      @farms = KepplerFarm::Farm.where.not(id: @farm.id)
      # @reasons = KepplerCattle::Transference.reasons
    end

    def create
      @transference = KepplerCattle::Transference.new(transference_params)

      unless @transference.from_farm_id == @transference.to_farm_id
        if @transference.save!
          @transference.cows.map { |x| x.status.update(farm_id: @transference.to_farm_id) }
          redirect_to app_farm_transferences_path(@farm)
        else
          flash[:error] = 'Revisa los datos del formulario'
          render :new
        end
      else
        flash[:error] = 'Error: Las fincas no pueden ser iguales'
        render :new
      end
    end

    def update
      if @transference.update(transference_params)
        redirect_to app_farm_transferences_path(@farm)
      else
        render :edit
      end
    end

    def edit; end

    # DELETE /cattles/1
    def destroy
      @transference.destroy
      redirect_to app_farm_transferences_path(@farm)
    end

    def destroy_multiple
      Transference.destroy redefine_ids(params[:multiple_ids])
      redirect_to app_farm_transferences_path(@farm)
    end

    private

    def set_transference
      @transference = KepplerCattle::Transference.find_by(id: params[:transference_id])
    end

    def index_variables
      @q = KepplerCattle::Transference.ransack(params[:q])
      transferences = @q.result(distinct: true)
      @transferences = transferences.page(@current_page).where_from(@farm.id).order(created_at: :desc)
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

    def set_farm
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
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
    def transference_params
      params.require(:transference).permit(
        { cattle: [] }, :from_farm_id, :to_farm_id, :reason
      )
    end
  end
end
