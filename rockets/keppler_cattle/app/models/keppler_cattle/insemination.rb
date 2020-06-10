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
    include KepplerCattle::Concerns::Ageable
    acts_as_list
    acts_as_paranoid

    validates_presence_of :birthdate, :serie_number, :farm_id
    validates_uniqueness_of :serie_number

    def self.index_attributes
      %i[serie_number species_id race_id]
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

    def self.farm
      KepplerFarm::Farm.find_by(id: $request.params[:farm_id])
    end

    def self.actives
      farm.inseminations.where('quantity > 0')
    end

    def self.inactives
      farm.inseminations.where('quantity = 0')
    end

    def self.colors
      ['No Registrado',
      'Cenizo',
      'Pardo',
      'Encerado',
      'Rojo',
      'Amarillo',
      'Pinto',
      'Blanco',
      'Negro',
      'Colorado']
    end

    def possible_typologies
      KepplerCattle::Typology
        .where(gender: 'male')
        .or(
          KepplerCattle::Typology
          .where(species_id: species_id)
        )
    end

    def typology
      KepplerCattle::Typology.find_by(id: id)
    end

    def mother
      KepplerCattle::Cow.find_by(id: mother_id) if mother_id
    end

    def father
      KepplerCattle::Cow.find_by(id: father_id) if father_id
    end

    def sons
      KepplerCattle::Cow.where(mother_id: id).or(
        KepplerCattle::Cow.where(father_id: id)
      )
    end
  end
end
