# frozen_string_literal: true

module KepplerCattle
  # Inventory Model
  class Inventory < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :farm, class_name: 'KepplerFarm::Farm'
    has_many :inventory_cows, class_name: 'KepplerCattle::InventoryCow'
    has_many :cows, class_name: 'KepplerCattle::Cow', through: :inventory_cows

    validates_presence_of :name

    def self.index_attributes
      %i[]
    end
  end
end
