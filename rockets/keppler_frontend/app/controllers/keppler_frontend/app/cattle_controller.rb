require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::CattleController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_cow, only: %i[show edit update destroy males toggle_milking create_activities]
    before_action :cow_attributes, only: %i[new edit create]
    before_action :index_variables
    before_action :attachments
    # before_action :index_history, only: %i[index index_inactives]
    before_action :show_history, only: %i[show]
    before_action :respond_to_formats
    before_action :user_authenticate
    before_action :redirect_to_species
    include ObjectQuery

    def index
      @active_cows = @cows.actives.order(:serie_number)
      if %i[html js].include? request.format.symbol
        @page_active_cows = @active_cows.page(params[:page]).per(50)
      end
    end

    def index_inactives
      @inactive_cows = @cows.inactives.order(:serie_number)
      if %i[html js].include? request.format.symbol
        @page_inactive_cows = @inactive_cows.page(params[:page]).per(50)
      end
    end

    def search
      url = Rails.application.routes.recognize_path(request.referrer)
      render controller: url[:controller], action: url[:action]
    end

    def show
      # respond_to_formats(@cow)
    end

    def new
      @cow = @farm_cows.new
    end

    def create
      if @farm_cows.find_by(serie_number: cow_params[:serie_number])
        flash[:error] = 'El número de serie ya está tomado'
        redirect_to new_farm_cow_path(@farm)
        return false
      end
      @cow = @farm_cows.new(cow_params)
      if params.dig(:cow, :father_id)
        @cow.father_type = params.dig(:cow, :father_id)&.split(',')&.first
        @cow.father_id = params.dig(:cow, :father_id)&.split(',')&.last&.to_i
      end

      if @cow.save! && @cow.weights.blank?
        @cow.create_first_location({farm_id: @farm.id})
        @cow.create_first_activity({user_id: current_user.id})
        @cow.create_typology
        @cow.mother.create_typology unless @cow.mother.blank?
        redirect_to new_farm_cow_weight_path(@farm, @cow)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @cow.update(cow_params)
        if params.dig(:cow, :father_id)
          @cow.update(father_type: params.dig(:cow, :father_id)&.split(',')&.first)
          @cow.update(father_id: params.dig(:cow, :father_id)&.split(',')&.last&.to_i)
        end
        if params.dig(:cow, :typology_ids)
          typology_id = params.dig(:cow, :typology_ids)
          cow_typology = @cow.cow_typologies.new(typology_id: typology_id)
          flash[:notice] = "La tipología ha sido actualizada a #{cow_typology&.typology&.name}" if cow_typology.save
        end
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
      @farm_cows.destroy redefine_ids(params[:multiple_ids])
      redirect_to farm_cows_path(@farm)
    end

    def get_races
      @races = KepplerCattle::Species.find(params[:species_id]).races
      respond_to do |format|
        format.js
      end
    end

    def batch_loading
    end

    def new_weights
      @cows = @farm_cows.where(id: params[:multiple_ids].split(','))
    end

    def create_weights
      params.require(:weight).keys.each do |cow_id|
        weight = KepplerCattle::Weight.new(multiple_cows_params(cow_id).values[0])
        if weight.save!
          flash[:notice] = "Pesos fueron guardados correctamente"
        else
          flash[:error] = "Error al guardar los pesos"
        end
      end
      redirect_to weights_farm_cows_path(@farm, params[:weight].keys.join(','))
    end

    def show_weights
      @cows = @farm_cows.where(id: params[:multiple_ids].split(',')).order(:serie_number)
    end

    def males
      @male = KepplerCattle::Male.find_or_create_by(cow_id: @cow&.id)
      if @male.update!(male_params)
        flash[:notice] = 'Estado de ganado macho ha sido cambiado'
      else
        flash[:error] = 'No se ha podido guardar el estado del ganado'
      end
      redirect_to [@farm, @cow]
    end

    def toggle_milking
      @cow.update!(milking: true, milking_date: Date.today)
      redirect_back fallback_location: farm_milk_index_path(@farm)
    end

    def start_milking
      @cow.update!(milking: true, milking_date: Date.today)
      redirect_back fallback_location: farm_milk_index_path(@farm)
    end

    def stop_milking
      @cow.update!(milking: nil)
      redirect_back fallback_location: farm_milk_index_path(@farm)
    end

    def create_activities
      @activity = @cow.cow_activities.new(activity_params)

      if @activity&.save
        flash[:notice] = 'Serie actualizada'
      else
        flash[:error] = 'No se pudo actualzar la serie'
      end
      redirect_to [@farm, @cow]
    end

    def create_pregnancies
      status = KepplerCattle::Status.new_status(params, {farm_id: @farm.id })
      cow = KepplerCattle::Cow.find_by_id(
        params.dig(:status, :cow_id) || params[:cow_id]
      )
      if status.save!
        flash[:notice] = 'Servicio guardado'
      else
        flash[:error] = 'No se pudo guardar el servicio'
      end
      redirect_back fallback_location: farm_cows_path(@farm)
    end

    def make_birth
      new_birth(params) if params
      if @status.save! && @baby_saved
        flash[:notice] =
          if @other_baby_saved
            'Parto realizado y morochos guardados'
          else
            'Parto realizado y becerro/a guardado'
          end
      else
        flash[:error] = 'No se pudo realizar el parto'
      end
      redirect_back fallback_location: farm_cows_path(@farm)
    end

    def new_services
      @cows = @farm_cows.where(id: params[:multiple_ids].split(','))
      @found = false
    end

    def create_services
      cow = @farm_cows.find(params[:status][:cow_id])
      insemination = @farm.inseminations.find(params[:status][:insemination_id])
      if params[:status][:insemination_quant].to_i > insemination.quantity.to_i
        flash[:error] = 'La cantidad de cartuchos no puede ser mayor a la existente'
      else
        if params[:status][:insemination_quant].to_i < 1
          flash[:error] = 'La cantidad de cartuchos debe ser superior a cero'
        else
          status = KepplerCattle::Status.new_status(params, {farm_id: @farm.id, user: params[:status][:user_name]})
          unless insemination.quantity.to_i.zero?
            insemination.update(
              quantity: insemination.quantity.to_i - params[:status][:insemination_quant].to_i
            )
          end
          flash[:notice] = 'Servicio guardado' if status.save!
        end
      end
      redirect_back fallback_location: farm_cows_path(@farm)
    end

    def new_pregnancies
      @cows = @farm_cows.where(id: params[:multiple_ids].split(','))
      @possible_fathers = @farm_cows.possible_fathers_select2
      @found = false
    end

    def create_pregnancies
      status = KepplerCattle::Status.new_status(params, {farm_id: @farm.id})
      if status.save!
        flash[:notice] = 'Preñez guardada'
      else
        flash[:error] = 'No se pudo guardar la preñez'
      end
      redirect_back fallback_location: farm_cows_path(@farm)
    end

    def new_births
      @cows = @farm_cows.where(id: params[:multiple_ids].split(','))
      @possible_fathers = @farm_cows.possible_fathers_select2
      @found = false
    end

    def create_births
      status = KepplerCattle::Status.new_status(params, {farm_id: @farm.id})
      if status.save!
        flash[:notice] = 'Parto guardado'
      else
        flash[:error] = 'No se pudo guardar el parto'
      end
      redirect_back fallback_location: farm_cows_path(@farm)
    end

    def make_abort
      @cow = @farm_cows.find(params[:abort][:cow_id])
      @abort = @cow.aborts.new(
        abort_date: params[:abort][:date],
        reason: params[:abort][:reason],
        observations: params[:abort][:observations]
      )

      if @abort.save!
        @cow.statuses.new_status(params, status_type: 'Nil')
        flash[:notice] = 'Aborto realizado satisfactoriamente'
      else
        flash[:error] = 'No se pudo realizar el parto'
      end

      redirect_back fallback_location: farm_cows_path(@farm)
    end

    def wean
      @cow = KepplerCattle::Cow.find(params[:wean][:cow_id])
      @cow.weights.create(
        weight_date: params[:wean][:date],
        weight: params[:wean][:weight]
      )
      @strategic_lot = @farm.strategic_lots.find(params[:wean][:strategic_lot])
      @cow.locations.create(farm_id: @farm.id, strategic_lot_id: @strategic_lot.id)
      @cow.create_typology

      flash[:notice] = 'Becerro destetado satisfactoriamente'
      redirect_back fallback_location: farm_seasons_path
    end

    def history
      @activities = PublicActivity::Activity.includes(:trackable, :owner, recipient: [:species, :race]).where(
        trackable_type: KepplerCattle::Cow.to_s
      ).or(
        PublicActivity::Activity.includes(:trackable, :owner, recipient: [:species, :race]).where(
          recipient_type: KepplerCattle::Cow.to_s
        )
      ).order('created_at desc').limit(50)
    end

    private

    def set_cow
      @cow = KepplerCattle::Cow.find_by(id: (params[:cow_id] || params[:id]))
    end

    def index_variables
      @farm = KepplerFarm::Farm.find_by(id: (params[:farm_id] || params[:id]))
      @q = KepplerCattle::Cow.includes(:locations).where(keppler_cattle_locations: { farm_id: @farm.id }).ransack(params[:q])
      @cows = @q.result(distinct: true)
      @active_cows_size = @cows.actives.size
      @inactive_cows_size = @cows.inactives.size
      @attributes = KepplerCattle::Cow.index_attributes
      @typologies = KepplerCattle::Typology.all
      # @strategic_lots = @farm.strategic_lots.map { |x| "'#{x.id}': '#{x.name}'" }.join(', ')
    end

    def cow_attributes
      @species = KepplerCattle::Species.all
      @genders = KepplerCattle::Cow.genders
      @races   = @species.first.races
      @possible_mothers = @farm_cows.possible_mothers_select2
      @possible_fathers = @farm_cows.possible_fathers_select2
      @colors = KepplerCattle::Cow.colors
    end

    def redirect_to_species
      @species = KepplerCattle::Species.all
      @typologies = KepplerCattle::Typology.all
      if @species.blank? || @species.select { |s| s.races.blank? }.size > 0 || @typologies.blank?
        redirect_to admin_cattle_species_index_path, notice: 'Debe llenar las especies con sus respectivas razas'
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

    def new_birth(params)
      @mother = @farm_cows.find_by_id(params[:status][:cow_id])
      @status = KepplerCattle::Status.new_status(params, { farm_id: @farm.id })
      if params[:status][:successfully] == '1'
        @baby_saved = create_cow(
          @mother,
          @status,
          new_cow_params,
          new_cow_weight_params
        )
      end
      unless params[:other_new_cow][:serie_number].blank?
        @other_baby_saved = create_cow(
          @mother,
          @status,
          other_new_cow_params,
          other_new_cow_weight_params
        )
      end
    end

    def create_cow(mother, this_status, params, weight_params)
      baby = @farm_cows.new(params)
      baby.species_id = mother&.species_id
      baby.mother_id = mother&.id
      baby.birthdate = this_status&.date || Date.today
      baby.provenance = mother&.farm.title
      if mother.statuses.where(status_type: 'Service')&.last&.insemination_id
        last_pregnancy = mother.statuses.where(status_type: 'Service')&.last
        father = @farm.inseminations.find_by_id(last_pregnancy&.insemination_id)
        baby.father_type = father.class.to_s
        baby.father_id = father&.id
      end

      if baby.save!
        baby.create_first_weight(
          weight_params,
          {
            user: @farm.responsables.find_or_create_by(name: this_status.user.name),
            user_id: @farm.responsables.find_or_create_by(name: this_status.user.name).id,
            cow_id: this_status.cow_id
          }
        )
        baby.create_first_location(
          {
            user_id: this_status.user,
            farm_id: @farm.id,
            strategic_lot_id: mother.strategic_lot&.id
          }
        )
        baby.create_first_activity({user_id: current_user.id})
        baby.create_typology
      end
    end

    def new_cow_params
      params.require(:new_cow).permit(
        KepplerCattle::Cow.attribute_names.map(&:to_sym)
      )
    end

    def other_new_cow_params
      params.require(:other_new_cow).permit(
        KepplerCattle::Cow.attribute_names.map(&:to_sym)
      )
    end

    def new_cow_weight_params
      params.require(:new_cow_weight).permit(
        KepplerCattle::Weight.attribute_names.map(&:to_sym)
      )
    end

    def other_new_cow_weight_params
      params.require(:other_new_cow_weight).permit(
        KepplerCattle::Weight.attribute_names.map(&:to_sym)
      )
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
    def activity_params
      params.require(:activity).permit(
        KepplerCattle::Activity.attribute_names.map(&:to_sym)
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
