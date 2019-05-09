# frozen_string_literal: true

module KepplerCattle
  # Weight Model
  class Weight < ApplicationRecord
    include ActivityHistory
    tracked recipient: -> (controller, _) { _.cow }
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    include KepplerCattle::Concerns::CreateCowTypology
    acts_as_list
    acts_as_paranoid
    after_save :create_typology

    belongs_to :user, class_name: 'KepplerFarm::Responsable', optional: true
    belongs_to :cow, class_name: 'KepplerCattle::Cow'
    belongs_to :corporal_condition, class_name: 'KepplerCattle::CorporalCondition'

    validates_presence_of :cow_id, :weight, :gained_weight, :average_weight

    def self.index_attributes
      %i[weight gained_weight average_weight]
    end
  end
end
