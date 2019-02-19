module KepplerFrontend
  # AppController -> Controller out the back-office
  class App::AppController < ::ApplicationController
    layout 'app/layouts/application'
    skip_before_action :verify_authenticity_token
    before_action :set_default_locale
    before_action :set_locale
    before_action :set_metas
    before_action :set_analytics

    include KepplerCapsules::Concerns::Lib
    def set_metas
      @theme_color = nil
      # Descomentar el modelo que exista depende del proyecto
      # @post = KepplerBlog::Post.find_by(id: params[:id])
      # @product = Product.find_by(id: params[:id])
      # @setting = Setting.includes(:social_account).first
      @meta = MetaTag.get_by_url(request.url)
      @social = @setting.social_account
      @meta_title = MetaTag.title(@post, @product, @setting)
      @meta_description = MetaTag.description(@post, @product, @setting)
      @meta_image = MetaTag.image(request, @post, @product, @setting)
      @meta_locale = @locale.eql?('es') ? 'es_VE' : 'en_US'
      @meta_locale_alternate = @locale.eql?('es') ? 'en_US' : 'es_VE'
      @country_code = @locale.eql?('es') ? 'VE' : 'US'
    end

    private

    def live_editor_info      
      if params[:editor] && controller_name.eql?('frontend') && !action_name.eql?('keppler')
        view = View.find_by(id: params[:view])
        gon.editor = view.live_editor_render
      end
    end

    def rocket(name, model)
      name = name.downcase.camelize
      model = model.singularize.downcase.camelize
      "Keppler#{name}::#{model}".constantize
    end

    def set_default_locale
      I18n.default_locale = KepplerLanguages::Language.where(active: true).first.try(:name)&.to_sym || :en
    end

    def set_locale
      if params[:locale]
        @locale = I18n.locale = params[:locale]
      elsif request.env['HTTP_ACCEPT_LANGUAGE']
        @locale = I18n.locale = I18n.default_locale
      end
    end

    def default_url_options(options = {})
      logger.debug "default_url_options is passed options: #{options.inspect}\n"
      { locale: :es }
    end

    def set_analytics
      @scripts = Script.select { |x| x.url == request.env['PATH_INFO'] }
    end

    def url_front
      "#{Rails.root}/rockets/keppler_frontend"
    end

    def redefine_ids(rocket, ids)
      return if ids.nil?
      ids.delete('[]').split(',').select do |id|
        id if frontend_model(rocket).exists? id
      end
    end

    # Classify a model from a controller
    def frontend_model(rocket)
      klass = controller_path
        .remove('app/').remove('admin/').remove('keppler_frontend/')
      "keppler_#{rocket}/#{klass}".classify.constantize
    end
  end
end
