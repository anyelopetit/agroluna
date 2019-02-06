# frozen_string_literal: true

module KepplerCattle
  # Insemination Model
  class Insemination < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    validates_presence_of :serie_number, :birthdate

    def self.index_attributes
      %i[serie_number species_id race_id corporal_condition]
    end

    def species
      KepplerCattle::Species.find_by(id: species_id)
    end

    def race
      KepplerCattle::Race.find_by(id: race_id)
    end

    def farm
      KepplerFarm::Farm.find_by(id: farm_id)
    end
  end
end
