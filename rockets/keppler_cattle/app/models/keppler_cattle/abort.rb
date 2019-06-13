# frozen_string_literal: true

module KepplerCattle
  # Abort Model
  class Abort < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :cow, class_name: 'KepplerCattle::Cow'
    belongs_to :season, class_name: 'KepplerReproduction::Season'
  end
end
