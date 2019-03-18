# frozen_string_literal: true

module KepplerReproduction
  # Cicle Model
  class Cicle < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :season, class_name: 'KepplerReproduction::Season'

    def self.index_attributes
      %i[name]
    end
  end
end
