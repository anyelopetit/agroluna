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

    belongs_to :species

    def self.index_attributes
      %i[name min_days specific_day max_days]
    end
  end
end
