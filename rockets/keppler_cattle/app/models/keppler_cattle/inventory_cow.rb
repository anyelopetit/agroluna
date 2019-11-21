# frozen_string_literal: true

module KepplerCattle
  # InventoryCow Model
  class InventoryCow < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :inventory, class_name: 'KepplerCattle::Inventory'
    belongs_to :cow, class_name: 'KepplerCattle::Cow'

    delegate :farm, to: :inventory

    def self.index_attributes
      %i[serie_number]
    end
  end
end
