# frozen_string_literal: true

module KepplerCattle
  # Race Model
  class Race < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid
    
    belongs_to :species

    validates_length_of :abbreviation, maximum: 6, message: 'Las abreviaciones no pueden exceder de 6 caracteres'

    def self.index_attributes
      %i[name abbreviation]
    end

    def species
      KepplerCattle::Species.find_by(id: species_id)
    end
  end
end
