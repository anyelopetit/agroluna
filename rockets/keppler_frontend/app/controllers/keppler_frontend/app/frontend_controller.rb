require_dependency "keppler_frontend/application_controller"
module KepplerFrontend
  class App::FrontendController < App::AppController
    # Begin callbacks area (don't delete)
    # End callbacks area (don't delete)
    include FrontsHelper
    layout 'keppler_frontend/app/layouts/application'
    # layout 'layouts/templates/application'
    before_action :set_farm, except: %i[root landing]
    before_action :set_farms
    before_action :default_logo
    before_action :attachments
    before_action :last_page
    before_action :user_authenticate
    before_action :respond_to_formats
    
    include ObjectQuery

    def root
      if current_user
        redirect_to landing_path
      else
        redirect_to main_app.new_user_session_path, locale: :es
      end
    end

    # begin index
    def landing
      case current_user.role_ids[0]
      when 1
        if KepplerFarm::Farm.all.count > 0
          redirect_to app_farm_path(KepplerFarm::Farm.last)
        end
      else
        @assign = KepplerFarm::Assignment.where(user_id: current_user.id).first
        @farm = KepplerFarm::Farm.find_by(id: @assign.keppler_farm_farm_id) if @assign
        if @farm
          redirect_to app_farm_path(@farm)
        end
      end
    end
    # end index

    private

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

    def default_logo
      @default_logo = '/assets/keppler_frontend/app/logo_default.png.png'
    end

    # begin callback user_authenticate
    def user_authenticate
      redirect_to '/users/sign_in' unless user_signed_in?
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
      @activities = PublicActivity::Activity.where(
        trackable_type: model.to_s
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
