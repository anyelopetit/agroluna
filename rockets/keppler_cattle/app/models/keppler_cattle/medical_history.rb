# frozen_string_literal: true

module KepplerCattle
  # MedicalHistory Model
  class MedicalHistory < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    belongs_to :user
    belongs_to :cow, class_name: 'KepplerCattle::Cow', foreign_key: 'cow_id'
    acts_as_list
    acts_as_paranoid

    def self.index_attributes
      %i[]
    end
  end
end
