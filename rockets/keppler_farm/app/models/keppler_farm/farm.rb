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

    # Farm
    has_many :strategic_lots, class_name: 'KepplerFarm::StrategicLot'

    # Cattle
    # has_many :cow_locations, class_name: 'KepplerCattle::Location'
    # has_many :cows, -> { distinct }, class_name: 'KepplerCattle::Cow', through: :cow_locations
    has_many :inseminations, class_name: 'KepplerCattle::Insemination'
    has_many :transferences, class_name: 'KepplerCattle::Transference', foreign_key: 'from_farm_id'

    # Reproduction
    has_many :seasons, class_name: 'KepplerReproduction::Season'

    # accepts_nested_attributes_for :cows

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
      cow_ids = KepplerCattle::Cow.all.select { |c| c&.location&.farm_id&.eql?(id) if c&.location&.farm_id }.pluck(:id)
      KepplerCattle::Cow.where(id: cow_ids)
    end

    # def transferences
    #   transference_ids = KepplerCattle::Transference.all.select { |t| t&.from_farm_id&.eql?(id) || t&.to_farm_id&.eql?(id) }.pluck(:id)
    #   KepplerCattle::Transference.where(id: transference_ids)
    # end

    # def strategic_lots
    #   KepplerFarm::StrategicLot.where(farm_id: id)
    # end

    # def inseminations
    #   KepplerCattle::Insemination.where(farm_id: id)
    # end

    def activities
      ids = cows.pluck(:id)
      PublicActivity::Activity.where(trackable_id: ids)
        .or(PublicActivity::Activity.where(recipient_id: ids))
    end
  end
end
