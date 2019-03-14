# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Pregnancy < ApplicationRecord
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

    validates_presence_of :user_id, :cow_id

    def self.index_attributes
      %i[pregnancy_date pregancy_months observations reproductor_type reproductor_id]
    end
  end
end
