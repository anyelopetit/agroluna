require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::SeasonsController < App::FarmsController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_season, except: %i[index new destroy_multiple]
    before_action :season_types, only: %i[new edit create update]
    before_action :set_farm
    before_action :set_farms
    before_action :index_variables
    strategic_lot_states = %i[
      availables zeals services pregnants births new_services create_services
      new_pregnancies create_pregnancies make_birth
    ]
    before_action :strategic_lot_variables, only: strategic_lot_states
    before_action :attachments
    report_actions = %i[
      reproduction_cows zeals_report services_report next_palpation_report
      pregnants_report births_report calfs_report twins_report abort_cows_report
      efectivity_report vet_efectivity_report bulls_report weans_report
      inseminations_report typologies_report inactive_cows_report
    ]
    after_action :respond_to_formats, except: report_actions
    before_action :report_variables, only: report_actions
    helper KepplerFarm::ApplicationHelper
    include ObjectQuery

    def index
    end

    def show
      # @cicle = KepplerReproduction::Cicle.new
      # @strategic_lot = KepplerFarm::StrategicLot.new
      @cows = @season.cows.where(gender: 'female').order(:serie_number)
      @bulls = @season.cows.where(gender: 'male')
      @season_cow = KepplerReproduction::SeasonCow.new
      @strategic_lots = @farm.strategic_lots
      @cow_strategic_lots = @strategic_lots.includes(:locations).where(
        keppler_cattle_locations: { cow_id: @cows.ids }
      ).distinct
      @possible_mothers = @farm.cows.possible_mothers
      @inseminated_cows = @season.cows.select do |c|
        c.status&.status_type&.eql?('Service')
      end
      @pregnants = @cows.where_status('Pregnancy', @season.id)
      # @colors = KepplerCattle::Cow.colors
      @babies = @cows.map { |c| c.sons.select { |s| s.typology.min_age < 210 } }.flatten
    end

    def new
      @season = KepplerReproduction::Season.new
    end

    def create
      @season = KepplerReproduction::Season.new(season_params)
      # @season.finish_date = params[:season][:finish_date]

      if @season.type_id.zero?
        counter = 0
        @farm.strategic_lots.each do |strategic_lot|
          counter += assign_cattle_each_lot(strategic_lot.id)
          if counter.zero?
            flash[:error] = 'No se agregaron series a la temporada'
          else
            flash[:notice] = "Se agregaron #{counter} series a la temporada"
          end
        end
      end

      if @season.save
        redirect_to farm_season_path(@farm, @season)
      else
        flash[:error] = 'Revisa los datos del formulario'
        render :new
      end
    end

    def update
      if @season.update(season_params)
        redirect_to farm_season_path(@farm, @season)
      else
        render :edit
      end
    end

    def edit; end

    # DELETE /farms/1
    def destroy
      @season.destroy
      redirect_to action: :index, farm_id: @farm&.id
    end

    def destroy_multiple
      if farm_ids = redefine_ids('farm', params[:multiple_ids])
        flash[:notice] = 'Las temporadas han sido eliminados'
        KepplerReproduction::Season.destroy farm_ids
      else
        flash[:error] = 'No se pudieron eliminar'
      end
      redirect_to farm_seasons_path(@farm)
    end
    
    def new_assign_cattle
      @bulls = @farm.possible_fathers
      @cows = @farm.possible_mothers
    end

    def assign_cattle
      if strategic_lot_id = params[:season_cow][:strategic_lot]
        counter = 0
        counter += assign_cattle_each_lot(strategic_lot_id)
        if counter.zero?
          flash[:error] = 'No se agregaron series a la temporada'
        else
          flash[:notice] = "Se agregaron #{counter} series a la temporada"
        end
      end
      redirect_to farm_season_path(@farm, @season)
    end

    def strategic_lot
      strategic_lot_id = params[:strategic_lot_id]
      @strategic_lot = @farm.strategic_lots.find(strategic_lot_id) if strategic_lot_id
      @bulls = @season.cows.total_season_bulls(@strategic_lot)
      @season_cow = KepplerReproduction::SeasonCow.new
    end

    def availables
      @cows = @season.cows.total_season_cows(@strategic_lot).type_is(['Nil', nil])
    end

    def zeals
      @cows = @season.cows.total_season_cows(@strategic_lot).type_is(['Zeal'])
    end

    def services
      @cows = @season.cows.total_season_cows(@strategic_lot).type_is(['Service'])
    end

    def pregnants
      @cows = @season.cows.includes(:species).total_season_cows(
        @strategic_lot).type_is(['Pregnancy']
      )
      # @species = KepplerCattle::Species.all
      @genders = KepplerCattle::Cow.genders
      # @possible_mothers = @farm.cows.possible_mothers_select2
      @possible_fathers = @farm.cows.possible_fathers_select2
      @colors = KepplerCattle::Cow.colors
    end

    def births
      @cows = @season.cows.total_season_cows(@strategic_lot).type_is(['Birth'])
    end

    def assign_bulls
      return unless params[:season_cow][:bulls]
      counter = 0
      strategic_lot_id = params[:strategic_lot_id]
      @strategic_lot = @farm.strategic_lots.find(strategic_lot_id) if strategic_lot_id
      params[:season_cow][:bulls].each do |bull_id|
        season_bull = @farm.cows.find(bull_id).season_cows.new(
          cow_id: bull_id,
          season_id: @season.id,
          strategic_lot_id: strategic_lot_id
        )
        counter += 1 if season_bull.save
      end
      flash[:notice] = "Se han agregado #{counter} toros a este lote"
      redirect_back fallback_location: availables_farm_season_path(
        @farm.id,
        @season.id,
        params[:strategic_lot_id]
      )
    end

    def destroy_season_cows
      params[:multiple_ids].split(',').each do |cow_id|
        season_cow = KepplerReproduction::SeasonCow.find_by(
          season_id: @season.id,
          cow_id: cow_id
        )
        season_cow.destroy! if season_cow
      end
      redirect_back fallback_location: availables_farm_season_path(
        @farm.id,
        @season.id,
        params[:strategic_lot_id]
      )
    end

    def statuses
      change_status(params)
      redirect_back fallback_location: availables_farm_season_path(
        @farm.id,
        @season.id,
        params[:strategic_lot_id]
      )
    end
      
    def new_services
      @cows = @season.cows.where(id: params[:multiple_ids].split(','))
      @found = false
    end
      
    def create_services
      cow = @season.cows.find(params[:status][:cow_id])
      insemination = @farm.inseminations.find(params[:status][:insemination_id])
      if params[:status][:insemination_quant].to_i > insemination.quantity.to_i
        flash[:error] = 'La cantidad de cartuchos no puede ser mayor a la existente'
      else
        if params[:status][:insemination_quant].to_i < 1
          flash[:error] = 'La cantidad de cartuchos debe ser superior a cero'
        else
          status = KepplerCattle::Status.new_status(params, {season_id: @season.id, farm_id: @farm.id, user: params[:status][:user_name]})
          unless insemination.quantity.to_i.zero?
            insemination.update(
              quantity: insemination.quantity.to_i - params[:status][:insemination_quant].to_i
            )
          end
          flash[:notice] = 'Servicio guardado' if status.save!
        end
      end
      redirect_back fallback_location: availables_farm_season_path(
        @farm.id,
        @season.id,
        params[:strategic_lot_id]
      )
    end

    def new_pregnancies
      @cows = @season.cows.where(id: params[:multiple_ids].split(','))
      @possible_fathers = @farm.cows.possible_fathers_select2
      @found = false
    end

    def create_pregnancies
      status = KepplerCattle::Status.new_status(params, {season_id: @season.id, farm_id: @farm.id})
      cow = KepplerCattle::Cow.find_by_id(
        params.dig(:status, :cow_id) || hash[:cow_id]
      )
      if status.save!
        flash[:notice] = 'Servicio guardado'
      else
        flash[:error] = 'No se pudo guardar el servicio'
      end
      redirect_back fallback_location: pregnants_farm_season_path(
        @farm, 
        @season, 
        @strategic_lot || cow.strategic_lot.id
      )
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
      redirect_back fallback_location: births_farm_season_path(
        @farm, 
        @season, 
        @strategic_lot || @mother.strategic_lot.id
      )
    end

    def make_abort
      @cow = @season.cows.find(params[:abort][:cow_id])
      @abort = @cow.aborts.new(
        abort_date: params[:abort][:date],
        reason: params[:abort][:reason],
        observations: params[:abort][:observations],
        season_id: @season.id
      )

      if @abort.save!
        @cow.statuses.new_status(params, status_type: 'Nil')
        flash[:notice] = 'Aborto realizado satisfactoriamente'
      else
        flash[:error] = 'No se pudo realizar el parto'
      end

      redirect_back fallback_location: farm_season_path(
        @farm, 
        @season
      )
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

    def finish
      @season.update(finished: true)
      redirect_to farm_season_path(@farm, @season)
    end

    def change_phase
      @season.update(phase: @season.phase.to_i + 1)
      redirect_to farm_season_path(@farm, @season)
    end

    def reopen
      @season.update(finished: false)
      redirect_to farm_season_path(@farm, @season)
    end

    def reproduction_cows
      @possible_mothers = @farm.cows.possible_mothers
      @weight_average = @possible_mothers.weight_average(@possible_mothers)
      respond_to_formats
    end

    def zeals_report
      @zeals_cows = @season.cows.where_status('Zeal', @season.id)
      respond_to_formats
    end

    def services_report
      @services_cows = @season.cows.where_status('Service', @season.id)
      respond_to_formats
    end

    def next_palpation_report
      @next_palpation_cows = @season.cows.to_next_palpation(@season.id)
      respond_to_formats
    end

    def pregnants_report
      @pregnants_cows = @season.cows.where_status('Pregnancy', @season.id)
      respond_to_formats
    end

    def births_report
      @births_cows = @season.cows.where_status('Birth', @season.id)
      respond_to_formats
    end

    def calfs_report
      @calfs = @season.cows.map { |c| c.sons.select { |s| s.typology.min_age < 210 } }.flatten
      respond_to_formats
    end

    def twins_report
      @twins = @season.cows.where_status('Birth', @season.id).select { |c| c.statuses }
      respond_to_formats
    end

    def abort_cows_report
      @abort_cows = @season.cows.select { |c| !c.aborts.blank? }
      respond_to_formats
    end

    def efectivity_report
      @responsables = @farm.responsables.where(farm_id: @farm.id)
      @services = @season.statuses.where(status_type: 'Service', season_id: @season.id)
      respond_to_formats
    end

    def vet_efectivity_report
      @vets = @season.users.where(farm_id: @farm.id)
      respond_to_formats
    end

    def bulls_report
      @bulls = @season.cows.where(gender: 'male')
      respond_to_formats
    end

    def belly_report
      @calfs = @season.cows.map { |c| c.sons.select { |s| s.typology.min_age < 210 } }.flatten
      respond_to_formats
    end

    def weans_report
      @calfs = @season.cows.map { |c| c.sons.select { |s| s.typology.min_age < 210 } }.flatten
      respond_to_formats
    end

    def inseminations_report
      @inseminations = @farm.inseminations
      respond_to_formats
    end

    def typologies_report
      @typologies = KepplerCattle::Typology.includes(:cows).all
      respond_to_formats
    end

    def inactive_cows_report
      @inactive_cows = @farm.cows.inactives
      respond_to_formats
    end

    private

    def season_types
      @season_types = KepplerReproduction::Season.types
    end

    def set_season
      @season = KepplerReproduction::Season.find_by(id: params[:id])
    end

    def report_variables
      @strategic_lots = @farm.strategic_lots
      @cows = @season.cows.order(:serie_number)
      @cow_strategic_lots = @strategic_lots.cows_strategic_lots(@cows.ids)
    end

    def change_status(params)
      if params[:status]
        counter = 0
        if params[:status][:multiple_ids]
          params[:status][:multiple_ids].split(',').each do |cow_id|
            status = KepplerCattle::Status.new_status(params, {cow_id: cow_id, season_id: @season.id, farm_id: @farm.id})
            insem = @farm.inseminations.find_by(id: status[:insemination_id])
            if insem && !insem&.quantity&.zero?
              insem.update(quantity: insem.quantity - 1)
            end
            counter += 1 if status.save!
          end
        end
        if counter.zero?
          flash[:error] = 'No se cambió el estado de ninguna serie'
        else
          flash[:notice] = "Se cambió el estado de #{counter} series"
        end
      end
    end

    def index_variables
      @q = @farm.cows.ransack(params[:q])
      cows = @q.result(distinct: true)
      @cows = cows.page(@current_page).order(position: :desc)
      @total = @cows.size
      @attributes = KepplerReproduction::Season.index_attributes
      @seasons = @farm.seasons
    end

    def strategic_lot_variables
      @season_cow = KepplerReproduction::SeasonCow.new
      strategic_lot_id = params[:strategic_lot_id]
      @strategic_lot = @farm.strategic_lots.find_by(id: strategic_lot_id)
      return false unless @strategic_lot
      @bulls = @season.cows.total_season_bulls(@strategic_lot)
      @cows = @season.cows.total_season_cows(@strategic_lot)
    end

    def set_farm
      @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
    end

    def set_farms
      if current_user&.has_role?('keppler_admin')
        @farms = KepplerFarm::Farm.all
      else
        @locations = KepplerFarm::Assignment.where(user_id: current_user&.id)
        @farms = KepplerFarm::Farm.where(
          id: @locations&.map(&:keppler_farm_farm_id)
        ) unless @locations.size.zero?
      end
    end

    def assign_cattle_each_lot(strategic_lot_id)
      return unless strategic_lot_id
      counter = 0
      strategic_lot = @farm.strategic_lots.find(
        strategic_lot_id
      )
      strategic_lot.cows.possible_mothers.each do |cow|
        season_cow = @season.season_cows.new(
          cow_id: cow.id,
          strategic_lot_id: strategic_lot_id
        )
        if season_cow.save
          status_nil = cow.statuses.new_status(params, {status_type: 'Nil', season_id: @season.id, farm_id: @farm.id})
          status_nil.save!
          counter += 1
        end
      end
      counter
    end
    
    def new_birth(params)
      @mother = @season.cows.find_by_id(params[:status][:cow_id])
      @status = KepplerCattle::Status.new_status(params, {season_id: @season.id, farm_id: @farm.id})
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
      baby = @farm.cows.new(params)
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
        baby_weight = baby.create_first_weight(
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

    def respond_to_formats(options = nil)
      respond_to do |format|
        format.html
        format.csv # { send_data KepplerReproduction::Season.all.to_csv, filename: "lotes estratégicos.csv" }
        format.xls # { send_data KepplerReproduction::Season.all.to_a.to_xls, filename: "lotes estratégicos.xls" }
        format.json
        format.pdf { render pdf_options }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def season_params
      params.require(:season).permit(
        KepplerReproduction::Season.attribute_names.map(&:to_sym)
      )
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
  end
end
