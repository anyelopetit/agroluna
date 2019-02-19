module KepplerCattle
  module ApplicationHelper

    def translate_cattle(word)
      I18n.t("keppler_cattle.#{word}") 
    end

    def current_translations 
      @translations ||= I18n.backend.send(:translations) 
      @translations[I18n.locale].with_indifferent_access 
    end

    def es_translations 
      @translations ||= I18n.backend.send(:translations) 
      @translations[:es].with_indifferent_access 
    end

    def cow_parent_id(value)
      parent_model = KepplerCattle::Cow.find_by(id: value)
    end
  end
end
