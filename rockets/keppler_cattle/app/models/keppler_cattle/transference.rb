# frozen_string_literal: true

module KepplerCattle
  # Transference Model
  class Transference < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    def self.index_attributes
      %i[]
    end
  end
end
