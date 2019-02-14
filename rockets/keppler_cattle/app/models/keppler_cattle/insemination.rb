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

    validates_presence_of :birthdate, :serie_number
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
    
    def self.active
      farm.inseminations.where(used: nil)
    end
    
    def self.inactive
      farm.inseminations.where.not(used: nil)
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

    def self.posible_mothers
      KepplerCattle::Cow.select { |x| x.gender?('female') }
        .map { |x| [x.serie_number + (" (#{x&.short_name})" unless x&.short_name.blank?).to_s, x.id] }
    end

    def self.posible_fathers
      KepplerCattle::Cow.select { |x| x.gender?('male') }
        .map { |x| [x.serie_number + (" (#{x&.short_name})" unless x&.short_name.blank?).to_s, x.id] }
    end

    def mother
      KepplerCattle::Cow.find_by(id: mother_id) if mother_id
    end

    def father
      KepplerCattle::Cow.find_by(id: father_id) if father_id
    end
  end
end