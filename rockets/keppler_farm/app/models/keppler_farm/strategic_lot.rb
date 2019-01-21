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

    def self.index_attributes
      %i[name function]
    end
  end
end
