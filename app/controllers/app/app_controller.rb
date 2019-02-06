# frozen_string_literal: true

module App
  # AppController -> Controller out the back-office
  class AppController < ::ApplicationController
    layout 'app/layouts/application'
    skip_before_action :verify_authenticity_token
    before_action :set_metas
    before_action :set_analytics
    before_action :set_default_locale

    def set_metas
      @theme_color = nil
      # Descomentar el modelo que exista depende del proyecto
      # @post = KepplerBlog::Post.find_by(id: params[:id])
      # @product = Product.find_by(id: params[:id])
      @setting = Setting.first
      @meta = MetaTag.get_by_url(request.url)
      @social = SocialAccount.last
      @meta_title = MetaTag.title(@post, @product, @setting)
      @meta_description = MetaTag.description(@post, @product, @setting)
      @meta_image = MetaTag.image(request, @post, @product, @setting)
      @meta_locale = @locale.eql?(:en) ? 'en_US' : 'es_VE'
      @meta_locale_alternate = @locale.eql?(:en) ? 'es_VE' : 'en_US'
      @country_code = @locale.eql?(:en) ? 'US' : 'VE'
    end

    private

    def default_url_options(options = {})
      logger.debug "default_url_options is passed options: #{options.inspect}\n"
      { locale: I18n.locale }
    end

    def set_analytics
      @scripts = Script.select { |x| x.url == request.env['PATH_INFO'] }
    end

    def set_default_locale
      @locale = I18n.default_locale = :es
      I18n.locale = :es
    end
  end
end
