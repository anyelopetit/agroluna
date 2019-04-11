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

    belongs_to :user, optional: true
    belongs_to :cow, class_name: 'KepplerCattle::Cow'
    belongs_to :farm, class_name: 'KepplerFarm::Farm'

    belongs_to :strategic_lot, class_name: "KepplerFarm::StrategicLot", foreign_key: "strategic_lot_id", optional: true

    validates_presence_of :cow_id, :farm_id

    def self.index_attributes
      %i[farm_id strategic_lot]
    end

    def exists?
      Location.where(cow_id: cow_id, strategic_lot_id: strategic_lot_id).exists?
    end

    def clean_other_cow_locations
      Location.where(cow_id: cow_id).destroy_all if Location.where(cow_id: cow_id).exists?
    end
  end
end
