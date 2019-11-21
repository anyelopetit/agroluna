# frozen_string_literal: true

module KepplerReproduction
  # Inefectivity Model
  class Inefectivity < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :user, class_name: 'KepplerFarm::Responsable', foreign_key: 'responsable_id', optional: true
    belongs_to :season, class_name: 'KepplerReproduction::Season', foreign_key: 'season_id', optional: true
    belongs_to :cow, class_name: 'KepplerCattle::Cow', foreign_key: 'cow_id'

    def self.index_attributes
      %i[]
    end
  end
end
