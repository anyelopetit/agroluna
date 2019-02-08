# frozen_string_literal: true

module KepplerCattle
  # Transference Model
  class Transference < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    def self.index_attributes
      %i[cattle from_farm_id to_farm_id]
    end

    def cows
      KepplerCattle::Cow.where(id: cattle)
    end

    def from_farm
      KepplerFarm::Farm.find_by(id: from_farm_id)
    end

    def to_farm
      KepplerFarm::Farm.find_by(id: to_farm_id)
    end

    def self.include_this_farm(farm)
      where(from_farm_id: farm.id).or(KepplerCattle::Transference.where(to_farm_id: farm.id)).order(created_at: :desc)
    end
    
    def self.where_from(params)
      where(from_farm_id: params)
    end
    
    def self.where_to(params)
      where(to_farm_id: params)
    end
  end
end
