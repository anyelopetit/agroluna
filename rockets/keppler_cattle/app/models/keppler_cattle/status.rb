# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Status < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :cow, class_name: 'KepplerCattle::Cow', foreign_key: 'cow_id'

    def self.index_attributes
      %i[]
    end
  end
end
