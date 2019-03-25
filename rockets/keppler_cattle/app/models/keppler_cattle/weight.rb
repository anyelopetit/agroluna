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
    include KepplerCattle::Concerns::Typologyable
    acts_as_list
    acts_as_paranoid
    after_save :create_typology

    belongs_to :user
    belongs_to :cow, class_name: 'KepplerCattle::Cow'
    belongs_to :corporal_condition, class_name: 'KepplerCattle::CorporalCondition'

    validates_presence_of :user_id, :cow_id, :corporal_condition_id

    def self.index_attributes
      %i[weight gained_weight average_weight]
    end
  end
end
