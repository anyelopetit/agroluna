# frozen_string_literal: true

module KepplerFarm
  # StrategicLot Model
  class StrategicLot < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    has_many :locations, class_name: 'KepplerCattle::Location', dependent: :destroy
    has_many :cows, class_name: 'KepplerCattle::Cow', through: :locations

    belongs_to :farm

    def self.index_attributes
      %i[name function]
    end

    def self.functions
      ['breeding', 'reproduction', 'lactating']
    end

    def cows
      locations = KepplerCattle::Location.where(strategic_lot_id: id).map(&:cow_id).uniq
      KepplerCattle::Cow.where(id: locations)
    end
  end
end
