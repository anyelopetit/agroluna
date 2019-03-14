# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Location < ApplicationRecord
    include ActivityHistory
    tracked recipient: -> (controller, _) { _.cow }
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    include KepplerCattle::Concerns::Ageable
    acts_as_list
    acts_as_paranoid

    belongs_to :user
    belongs_to :cow, class_name: 'KepplerCattle::Cow'
    belongs_to :farm, class_name: 'KepplerFarm::Farm'

    validates_presence_of :cow_id, :farm_id

    def self.index_attributes
      %i[farm_id strategic_lot]
    end
  end
end
