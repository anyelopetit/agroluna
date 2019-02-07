# frozen_string_literal: true

module KepplerFarm
  # Photo Model
  class Photo < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    mount_uploader :photo, AttachmentUploader
    acts_as_list
    acts_as_paranoid

    belongs_to :farm

    def farm
      KepplerFarm::Farm.find_by(id: farm_id)
    end

    def self.index_attributes
      %i[photo]
    end
  end
end
