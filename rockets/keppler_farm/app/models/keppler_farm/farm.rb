# frozen_string_literal: true

module KepplerFarm
  # Farm Model
  class Farm < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    mount_uploader :logo, AttachmentUploader
    acts_as_list
    acts_as_paranoid

    has_many :photos

    has_many :users
    has_many :assignments, through: :users

    def self.index_attributes
      %i[logo title photos strategic_lots]
    end
  end
end
