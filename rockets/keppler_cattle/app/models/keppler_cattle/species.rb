# frozen_string_literal: true

module KepplerCattle
  # Species Model
  class Species < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    validates_uniqueness_of :name, :abbreviation

    def self.index_attributes
      %i[name abbreviation]
    end

    def races
      KepplerCattle::Race.where(species_id: id)
    end

    def typologies
      KepplerCattle::Typology.where(species_id: id)
    end

    def weighing_days
      KepplerCattle::WeighingDay.where(species_id: id)
    end
  end
end
