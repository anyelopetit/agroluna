# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Status < ApplicationRecord
    include ActivityHistory
    tracked recipient: -> (controller, _) { _.cow }
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    belongs_to :cow
    acts_as_list
    acts_as_paranoid

    belongs_to :farm
    belongs_to :user

    validates_presence_of :farm_id

    def self.index_attributes
      %i[ubication corporal_condition typology]
    end

    def relation_id
      User.find_by(id: user_id).name
    end

    def self.corporal_conditions
      [
        'CONDICIÓN CORPORAL 1',
        'CONDICIÓN CORPORAL 2',
        'CONDICIÓN CORPORAL 3',
        'CONDICIÓN CORPORAL 4',
        'CONDICIÓN CORPORAL 5'
      ]
    end

    def self.strategic_lots
      KepplerFarm::StrategicLot.where(farm_id: status.farm_id)
    end

    # def self.male_typologies
    #   ['BECERRO', 'BECERRO SUTE', 'MAUTE', 'NOVILLO', 'TORO', 'TORO PADROTE']
    # end

    # def self.female_typologies
    #   ['BECERRA', 'BECERRA SUTE', 'MAUTA', 'NOVILLA', 'NOVILLA PREÑADA', 'VACA VACÍA',
    #   'VACA PROD.VACIA', 'VACA VACÍA SIN CRÍA', 'VACA PREÑADA', 'VACA SECA/HORRA']
    # end

    # def self.typologies
    #   ['BECERRO',
    #   'BECERRA',
    #   'MAUTE',
    #   'MAUTA',
    #   'NOVILLA',
    #   'NOVILLA PREÑADA',
    #   'NOVILLO',
    #   'TORO',
    #   'TORO PADROTE',
    #   'TORO RECELADOR',
    #   'VACA VACÍA',
    #   'VACA PROD.VACIA',
    #   'VACA VACÍA SIN CRÍA',
    #   'VACA PREÑADA',
    #   'VACA SECA/HORRA']
    # end

    def typology
      # KepplerCattle::Typology .find_by(id: typology_id)
    end

    def farm
      KepplerFarm::Farm.find_by(id: farm_id)
    end

    def farm_name
      KepplerFarm::Farm.find_by(id: farm_id).title
    end

    def user
      User.find_by(id: user_id) if user_id
    end

    def strategic_lot
      KepplerFarm::StrategicLot.find_by(id: strategic_lot_id) unless strategic_lot_id.nil?
    end

    def find_lot
      KepplerFarm::StrategicLot.find_by(id: cow&.status&.strategic_lot_id) if cow&.status&.strategic_lot_id
    end
  end
end
