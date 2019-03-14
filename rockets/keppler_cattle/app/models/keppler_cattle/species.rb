# frozen_string_literal: true

module KepplerCattle
  # Species Model
  class Species < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    has_many :cows, class_name: 'KepplerCattle::Cow'
    has_many :races, class_name: 'KepplerCattle::Race'
    has_many :typologies, class_name: 'KepplerCattle::Typology'
    has_many :weighing_days, class_name: 'KepplerCattle::WeighingDay'
    has_many :corporal_conditions, class_name: 'KepplerCattle::CorporalCondition'

    validates_uniqueness_of :name, :abbreviation

    def self.index_attributes
      %i[name abbreviation]
    end

    # def races
    #   KepplerCattle::Race.where(species_id: id)
    # end

    # def typologies
    #   KepplerCattle::Typology.where(species_id: id)
    # end

    # def weighing_days
    #   KepplerCattle::WeighingDay.where(species_id: id)
    # end
  end
end
