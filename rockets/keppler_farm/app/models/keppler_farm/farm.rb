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

    has_many :strategic_lots
    has_many :cows

    def self.index_attributes
      %i[logo title photos strategic_lots]
    end

    def photos
      KepplerFarm::Photo.where(farm_id: id)
    end

    def none_cover?
      photos.where(cover: true).count.zero?
    end

    def cows
      KepplerCattle::Cow.all.select { |c| c&.status&.farm_id&.eql?(id) if c&.status&.farm_id }
    end

    def transferences
      KepplerCattle::Transference.all.select { |t| t&.from_farm_id&.eql?(id) || t&.to_farm_id&.eql?(id) }
    end

    def strategic_lots
      KepplerFarm::StrategicLot.where(farm_id: id)
    end
  end
end
