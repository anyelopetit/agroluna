# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Status < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    belongs_to :cow
    acts_as_list
    acts_as_paranoid

    belongs_to :user

    def self.index_attributes
      %i[ubication corporal_condition typology]
    end

    def relation_id
      User.find(user_id).name
    end

    def self.corporal_conditions
      ['CONDICIÓN CORPORAL 1', 'CONDICIÓN CORPORAL 2', 'CONDICIÓN CORPORAL 3']
    end

    def self.ubications
      ['UBICACIÓN 1', 'UBICACIÓN 2', 'UBICACIÓN 3']
    end

    def self.strategic_lots
      ['LOTE ESTRATÉGICO 1', 'LOTE ESTRATÉGICO 2', 'LOTE ESTRATÉGICO 3']
    end

    def self.typologies
      ['BECERRO', 'BECERRA', 'MAUTE', 'MAUTA', 'NOVILLA', 'NOVILLA PREÑADA', 'NOVILLO',
      'TORO', 'TORO PADROTE', 'TORO RECELADOR', 'VACA VACÍA', 'VACA PROD.VACIA',
      'VACA VACÍA SIN CRÍA', 'VACA PREÑADA', 'VACA SECA/HORRA']
    end
  end
end
