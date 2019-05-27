# frozen_string_literal: true

module KepplerFarm
  # Responsable Model
  class Responsable < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :farm, class_name: 'KepplerFarm::Farm', optional: true
    belongs_to :season, class_name: 'KepplerReproduction::Season', optional: true
    
    has_many :inefectivities, class_name: 'KepplerReproduction::Inefectivity', foreign_key: 'responsable_id', dependent: :destroy
    has_many :statuses, ->(resp){ where(farm_id: resp.try(:farm_id)) }, class_name: 'KepplerCattle::Status', foreign_key: 'user_id'
    has_many :cow_statuses, ->(resp){ where(farm_id: resp.try(:farm_id)) }, class_name: 'KepplerCattle::Status', foreign_key: 'user_id'

    # validates_uniqueness_of :name

    def self.index_attributes
      %i[name]
    end

    def status_where(status_type, season_id)
      cow_statuses.where(status_type: status_type, season_id: season_id)
    end
  end
end
