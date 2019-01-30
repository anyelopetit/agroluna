require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::CattleController < App::FrontendController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_cow, only: %i[show edit update destroy]
    before_action :cow_attributes, only: %i[new edit create]
    before_action :set_farms
    before_action :index_variables
    before_action :attachments
    include ObjectQuery

    def index
      @typologies = KepplerCattle::Status.typologies
      respond_to_formats(KepplerCattle::Cow.all)
    end

    def show
      @statuses = @cow.statuses.order(id: :desc)
    end

    def new
      @cow = KepplerCattle::Cow.new
    end

    def create
      @cow = KepplerCattle::Cow.new(cow_params)

      if @cow.save && @cow.statuses.blank?
        # redirect(@cow, params)
        redirect_to app_farm_cow_status_new_path(@farm, @cow)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @cow.update(cow_params)
        if @cow.statuses.blank?
          redirect_to app_farm_cow_status_new_path(@farm, @cow)
        else 
          redirect_to app_farm_cow_path(@farm, @cow)
        end
      else
        render :edit
      end
    end

    def edit
    end

    # DELETE /cattles/1
    def destroy
      @cow.destroy
      redirect_to app_farm_cows_path(@farm)
    end

    def destroy_multiple
      Cow.destroy redefine_ids(params[:multiple_ids])
      redirect_to app_farm_cows_path(@farm)
    end

    private

    def set_cow
      @cow = KepplerCattle::Cow.find(params[:cow_id])
    end

    def index_variables
      @q = KepplerCattle::Cow.ransack(params[:q])
      @cows = @q.result(distinct: true)
      @active_cows = @cows.page(@current_page).actives(@farm)
      @inactive_cows = @cows.page(@current_page).inactives(@farm)
      @total = @cows.size
      @attributes = KepplerCattle::Cow.index_attributes
    end

    def cow_attributes
      @species = KepplerCattle::Cow.species
      @genders = KepplerCattle::Cow.genders
      @races   = KepplerCattle::Cow.races
      @posible_mothers = KepplerCattle::Cow.posible_mothers
      @posible_fathers = KepplerCattle::Cow.posible_fathers
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
    def cow_params
      params.require(:cow).permit(
        :serie_number,
        :image,
        :short_name,
        :long_name,
        :species,
        :gender,
        :birthdate,
        :race,
        :coat_color,
        :nose_color,
        :tassel_color,
        :provenance, 
        :observations,
        :mother_id,
        :father_id
      )
    end
  end
end
