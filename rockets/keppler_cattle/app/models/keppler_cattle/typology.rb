# frozen_string_literal: true

module KepplerCattle
  # Typology Model
  class Typology < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :species

    validates_presence_of :name

    def self.index_attributes
      %i[name abbreviation gender counter min_age min_weight]
    end

    def species
      KepplerCattle::Species.find_by(id: species_id)
    end

    def self.by_gender_and_species(cattle)
      where(gender: cattle.gender).or(where(species_id: cattle.species_id))
    end
  end
end
