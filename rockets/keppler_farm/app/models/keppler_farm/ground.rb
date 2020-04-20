# frozen_string_literal: true

module KepplerFarm
  # Ground Model
  class Ground < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    def self.index_attributes
      %i[identifier name location cultivation]
    end

    def efficiency
      "#{super}%"
    end

    def fecal_effectiveness
      "#{super}%"
    end

    def forage_offer
      "#{super}%"
    end

    def total_area
      super.to_i > 1 ? "#{super} has" : "#{super} ha"
    end

    def used_area
      super.to_i > 1 ? "#{super} has" : "#{super} ha"
    end
  end
end
