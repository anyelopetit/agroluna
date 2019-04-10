require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::CattleController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_cow, only: %i[show edit update destroy males]
    before_action :cow_attributes, only: %i[new edit create]
    before_action :set_farms
    before_action :index_variables
    before_action :attachments
    before_action :index_history, only: %i[index index_inactives]
    before_action :show_history, only: %i[show]
    before_action :respond_to_formats
    before_action :user_authenticate
    include ObjectQuery

    def index; end

    def index_inactives; end

    def search
      url = Rails.application.routes.recognize_path(request.referrer)
      render controller: url[:controller], action: url[:action]
    end

    def show
      # respond_to_formats(@cow)
    end

    def new
      @cow = KepplerCattle::Cow.new
    end

    def create
      @cow = KepplerCattle::Cow.new(cow_params)
      @cow.father_type = params[:cow][:father_id].split(',').first
      @cow.father_id = params[:cow][:father_id].split(',').last.to_i

      if @cow.save && @cow.weights.blank?
        @cow.mother.create_typology unless @cow.mother.blank?
        redirect_to new_farm_cow_weight_path(@farm, @cow)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @cow.update(cow_params)
        @cow.update(father_type: params[:cow][:father_id].split(',').first)
        @cow.update(father_id: params[:cow][:father_id].split(',').last.to_i)
        if @cow.weights.blank?
          redirect_to new_farm_cow_weight_path(@farm, @cow)
        else 
          redirect_to farm_cow_path(@farm, @cow)
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
      redirect_to farm_cows_path(@farm)
    end

    def destroy_multiple
      KepplerCattle::Cow.destroy redefine_ids(params[:multiple_ids])
      redirect_to farm_cows_path(@farm)
    end

    def get_races
      @races = KepplerCattle::Species.find(params[:species_id]).races
      respond_to do |format|
        format.js
      end
    end

    def new_weights
      @cows = @farm.cows.where(id: params[:multiple_ids].split(','))
    end

    def create_weights
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

    def show_weights
      @cows = @farm.cows.where(id: params[:multiple_ids].split(',')).order(:serie_number)
    end

    def males
      @male = KepplerCattle::Male.new(male_params)
      if @male.save!
        flash[:notice] = 'Estado de ganado macho ha sido cambiado'
      else
        flash[:error] = 'No se ha podido guardar el estado del ganado'
      end
      redirect_to [@farm, @cow]
    end

    private

    def set_cow
      @cow = KepplerCattle::Cow.find_by(id: params[:id])
    end

    def index_variables
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
      @q = KepplerCattle::Cow.ransack(params[:q]) # @farm.cows.ransack(params[:q])
      @cows = @q.result(distinct: true)
      @active_cows = @cows.actives.page(params[:page]).per(10)
      @inactive_cows = @cows.inactives.page(params[:page]).per(10)
      @attributes = KepplerCattle::Cow.index_attributes
      @typologies = KepplerCattle::Typology.all
      @strategic_lots = @farm.strategic_lots.map { |x| "'#{x.id}': '#{x.name}'" }.join(', ')
    end

    def cow_attributes
      @species = KepplerCattle::Species.all
      @genders = KepplerCattle::Cow.genders
      @races   = @species.first.races
      @possible_mothers = @farm.cows.possible_mothers_select2
      @possible_fathers = @farm.cows.possible_fathers_select2
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
      @activities = PublicActivity::Activity.includes(:trackable, :owner, recipient: [:species, :race]).where(
        trackable_type: KepplerCattle::Cow.to_s
      ).or(
        PublicActivity::Activity.includes(:trackable, :owner, recipient: [:species, :race]).where(
          recipient_type: KepplerCattle::Cow.to_s
        )
      ).order('created_at desc').limit(50)
    end

    def show_history
      @activities = PublicActivity::Activity.includes(:trackable, :owner, recipient: [:species, :race]).where(
        trackable_type: 'KepplerCattle::Cow',
        trackable_id: @cow&.id.to_s
      ).or(
        PublicActivity::Activity.includes(:trackable, :owner, recipient: [:species, :race]).where(
          recipient_type: 'KepplerCattle::Cow',
          recipient_id: @cow&.id.to_s
        )
      ).order('created_at desc').limit(50)
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
    def cow_params
      params.require(:cow).permit(
        KepplerCattle::Cow.attribute_names.map(&:to_sym)
      )
    end

    # Only allow a trusted parameter "white list" through.
    def male_params
      params.require(:male).permit(
        KepplerCattle::Male.attribute_names.map(&:to_sym)
      )
    end

    # Only allow a trusted parameter "white list" through.
    def multiple_cows_params(id)
      params.require(:weight).permit(
        "#{id}": KepplerCattle::Weight.attribute_names.map(&:to_sym)
      )
    end
  end
end
