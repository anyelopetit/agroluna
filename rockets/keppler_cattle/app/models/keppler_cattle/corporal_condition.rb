# frozen_string_literal: true

module KepplerCattle
  # Typology Model
  class CorporalCondition < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :species

    belongs_to :species, class_name: 'KepplerCattle::Species'
    validates_presence_of :name

    def self.index_attributes
      %i[name number description]
    end
  end
end
