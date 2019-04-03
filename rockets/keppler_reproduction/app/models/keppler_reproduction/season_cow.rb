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

    validate :verify_existence

    belongs_to :season, class_name: 'KepplerReproduction::Season'
    belongs_to :cow, class_name: 'KepplerCattle::Cow'

    def self.index_attributes
      %i[]
    end

    protected

    def verify_existence
      season_cows = KepplerReproduction::SeasonCow.where(season_id: season_id, cow_id: cow_id)
      errors.add(:season_cow, 'is created.') unless season_cows.count.zero?
      season_cows.count.zero?
    end
  end
end
