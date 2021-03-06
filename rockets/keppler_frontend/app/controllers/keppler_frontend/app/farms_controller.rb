require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FarmsController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm
    before_action :set_farms
    before_action :default_logo
    before_action :attachments
    before_action :last_page
    before_action :user_authenticate
    before_action :redirect_to_species
    
    include ObjectQuery

    def root
      if current_user
        redirect_to landing_farms_path
      else
        redirect_to main_app.new_user_session_path, locale: :es
      end
    end

    def landing
      case current_user.role_ids[0]
      when 1
        redirect_to KepplerFarm::Farm.last if KepplerFarm::Farm.all.exists?
      else
        @assign = KepplerFarm::Assignment.where(user_id: current_user.id).first
        @farm = KepplerFarm::Farm.find_by(id: @assign.keppler_farm_farm_id) if @assign
        redirect_to @farm if @farm
      end
    end

    def show; end
    
    def import_xls
    end

    private

    def set_farm
      @farm = KepplerFarm::Farm.find_by(id: (params[:farm_id] || params[:id]))
      return unless @farm

      @farm_cows =
        KepplerCattle::Cow.includes(:locations)
          .where(keppler_cattle_locations: { farm_id: @farm.id })
    end

    def set_farms
      if current_user&.has_role?('keppler_admin')
        @farms = KepplerFarm::Farm.all
      else
        @assignments = KepplerFarm::Assignment.where(user_id: current_user&.id)
        @farms = KepplerFarm::Farm.where(id: @assignments&.map(&:keppler_farm_farm_id)) unless @assignments.size.zero?
      end
    end

    def redirect_to_species
      @species = KepplerCattle::Species.all
      @races = KepplerCattle::Race.all
      @typologies = KepplerCattle::Typology.all
      if @species.blank? || @species.select { |s| s.races.blank? }.size > 0 || @typologies.blank?
        redirect_to admin_cattle_species_index_path
      end
    end

    def default_logo
      @default_logo = '/assets/keppler_frontend/app/logo_default.png.png'
    end

    # begin callback user_authenticate
    def user_authenticate
      redirect_to main_app.new_user_session_path, locale: :es unless user_signed_in?
    end
    # end callback user_authenticate

    def attachments
      @attachments = YAML.load_file(
        "#{Rails.root}/config/attachments.yml"
      )
    end

    def last_page
      session[:last_page] = request.env['HTTP_REFERER']
    end

    def get_history(model)
      @activities = PublicActivity::Activity.includes(:trackable, :owner).where(
        trackable_type: model.to_s
      ).order('created_at desc').limit(50)
    end
  end
end
