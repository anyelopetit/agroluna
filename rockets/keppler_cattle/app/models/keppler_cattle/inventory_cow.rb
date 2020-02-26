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
    belongs_to :cow, class_name: 'KepplerCattle::Cow', optional: true

    delegate :farm, to: :inventory

    validates_presence_of :serie_number

    scope :in_system, -> { where(found: true) }
    scope :in_farm, -> { where(in_farm: true) }
    scope :not_found_in_farm, -> { where(in_farm: [nil, false]) }

    def self.index_attributes
      %i[serie_number]
    end
  end
end
