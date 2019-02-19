# frozen_string_literal: true

module KepplerCattle
  # WeighingDay Model
  class WeighingDay < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    def self.index_attributes
      %i[name min_days specific_day max_days]
    end

    def species
      KepplerCattle::Species.find_by(id: species_id)
    end
  end
end
