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
    before_action :index_history, only: %i[index index_inactive]
    before_action :show_history, only: %i[show]
    before_action :respond_to_formats
    include ObjectQuery

    def index; end

    def index_inactive; end

    def show
      @statuses = @cow.statuses.order(id: :desc)
      # respond_to_formats(@cow)
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
      @cow = KepplerCattle::Cow.find_by(id: params[:cow_id])
    end

    def index_variables
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
      @q = KepplerCattle::Cow.ransack(params[:q]) # @farm.cows.ransack(params[:q])
      @cows = @q.result(distinct: true)
      @active_cows = @cows.actives.order(:serie_number)
      @inactive_cows = @cows.inactives.order(:serie_number)
      @total = @cows.size
      @attributes = KepplerCattle::Cow.index_attributes
      @typologies = KepplerCattle::Typology.all
    end

    def cow_attributes
      @species = KepplerCattle::Species.all
      @genders = KepplerCattle::Cow.genders
      @races   = KepplerCattle::Race.all
      @posible_mothers = KepplerCattle::Cow.posible_mothers
      @posible_fathers = KepplerCattle::Cow.posible_fathers
      @colors = KepplerCattle::Cow.colors
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

    def index_history
      @activities = PublicActivity::Activity.where(
        trackable_type: KepplerCattle::Cow.to_s
      ).or(
        PublicActivity::Activity.where(
          recipient_type: KepplerCattle::Cow.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def show_history
      @activities = PublicActivity::Activity.where(
        trackable_id: @cow.id.to_s
      ).or(
        PublicActivity::Activity.where(
          recipient_id: @cow.id.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def respond_to_formats
      respond_to do |format|
        format.html
        # format.csv { send_format_data(objects.model.all, 'csv') }
        # format.xls { send_format_data(objects.model.all, 'xls') }
        format.json
        format.pdf do
          render pdf_options
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def cow_params
      params.require(:cow).permit(
        :serie_number,
        :image,
        :short_name,
        :long_name,
        :species_id,
        :race_id,
        :gender,
        :birthdate,
        :coat_color,
        :nose_color,
        :tassel_color,
        :provenance, 
        :observations,
        :mother_id,
        :father_id
      )
    end

    protected

    def send_format_data(objects, extension)
      models = objects.model.to_s.downcase.pluralize
      t_models = t("keppler.models.pluralize.#{models}").humanize
      filename = "#{t_models} - #{I18n.l(Time.now, format: :short)}"
      objects_array = objects.order(:created_at)
      case extension
      when 'csv'
        send_data objects_array.to_csv, filename: "#{filename}.csv"
      when 'xls'
        send_data objects_array.to_a.to_xls, filename: "#{filename}.xls"
      end
    end
  end
end
