# frozen_string_literal: true

module KepplerReproduction
  # SeasonCow Model
  class SeasonCow < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :season, class_name: 'KepplerReproduction::Season'
    belongs_to :cow, class_name: 'KepplerCattle::Cow'

    def self.index_attributes
      %i[]
    end
  end
end
