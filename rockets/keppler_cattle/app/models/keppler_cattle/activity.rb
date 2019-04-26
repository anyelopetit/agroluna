# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Activity < ApplicationRecord
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

    validates_presence_of :cow_id

    def self.index_attributes
      %i[active created_at observations]
    end
  end
end
