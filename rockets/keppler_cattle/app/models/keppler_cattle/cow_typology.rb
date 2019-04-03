# frozen_string_literal: true

module KepplerCattle
  # CowTypology Model
  class CowTypology < ApplicationRecord
    include ActivityHistory
    tracked recipient: -> (controller, _) { _.cow }
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    # belongs_to :user
    belongs_to :cow, class_name: 'KepplerCattle::Cow'
    belongs_to :typology, class_name: 'KepplerCattle::Typology'

    validates_presence_of :cow_id, :typology_id
    validate :verify_existence, on: :create
    validate :verify_age_and_weight, on: :create
    validate :verify_counter, on: :create

    def self.index_attributes
      %i[user_id cow_id typology_id]
    end

    private

    def verify_existence
      cow_typologies = KepplerCattle::CowTypology.where(
        cow_id: cow_id,
        typology_id: typology_id
      )
      cow_typologies.count.zero?
    end

    def verify_age_and_weight
      age = cow.days.to_i > typology.min_age.to_i
      weight = cow.weight&.weight.to_f > typology.min_weight.to_f
      age && weight
    end

    def verify_counter
      if typology.counter.to_i == 1
        true # TOCHANGE
      elsif typology.counter.to_i == 2
        cow.sons.exists?
      else
        true
      end
    end
  end
end
