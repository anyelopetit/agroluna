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
    # validate :verify_age_and_weight, on: :create
    validate :verify_counter, on: :create

    def self.index_attributes
      %i[user_id cow_id typology_id]
    end

    private

    def verify_existence
      same_cow_typologies = KepplerCattle::CowTypology.where(
        cow_id: cow_id,
        typology_id: typology_id
      )
      errors.add(:typology, 'no puede agregarse la misma tipología') unless same_cow_typologies.size.zero?
    end

    def verify_age_and_weight
      age_is_able = cow&.days.to_i > typology&.min_age.to_i
      weight_is_able = cow.weight&.weight.to_f > typology&.min_weight.to_f
      unless age_is_able
        errors.add(:age, 'debe cumplir con la condiciónd de tipología')
      end
      unless weight_is_able
        errors.add(:weight, 'debe cumplir con la condiciónd de tipología')
      end
    end

    def verify_counter
      if typology.counter.to_i == 1 && cow.weaning.blank?
        errors.add(:typology, 'aún es una cría para esta tipología')
      elsif typology.counter.to_i == 2 && cow.sons.blank?
        errors.add(:typology, 'aún no posee crías para este tipología')
      else
        true
      end
    end
  end
end
