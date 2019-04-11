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

    validate :verify_days

    def self.index_attributes
      %i[name min_days specific_day max_days]
    end

    private

    def verify_days
      min_especific = min_days < specific_day
      specific_max = specific_day < max_days
      min_max = min_days < max_days
      min_especific && specific_max && min_max
    end
  end
end
