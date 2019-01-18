module KepplerCattle
  module ApplicationHelper

    def translate_cattle(word)
      I18n.t("keppler-cattle.#{word}") 
    end

    def current_translations 
      @translations ||= I18n.backend.send(:translations) 
      @translations[I18n.locale].with_indifferent_access 
    end
  end
end
