# frozen_string_literal: true

module KepplerCattle
  # Typology Model
  class Typology < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    has_many :cow_typologies, class_name: 'KepplerCattle::CowTypology', dependent: :destroy
    has_many :cows, class_name: 'KepplerCattle::Cow', through: :cow_typologies

    belongs_to :species

    validates_presence_of :name

    def self.index_attributes
      %i[name abbreviation gender counter min_age min_weight]
    end

    def species
      KepplerCattle::Species.find_by(id: species_id)
    end

    def self.by_gender_and_species(cattle)
      where(gender: cattle.gender, species_id: cattle.species_id)
    end
  end
end
