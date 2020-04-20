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

    has_many :responsables, -> { distinct }, class_name: 'KepplerFarm::Responsable', foreign_key: :farm_id
    has_many :assignments, through: :responsables

    # Farm
    has_many :strategic_lots, class_name: 'KepplerFarm::StrategicLot'

    # Cattle
    has_many :cow_locations, class_name: 'KepplerCattle::Location'
    # has_many :cows, -> (farm) { distinct }, class_name: 'KepplerCattle::Cow', through: :cow_locations
    has_many :inseminations, class_name: 'KepplerCattle::Insemination'
    has_many :transferences, class_name: 'KepplerCattle::Transference', foreign_key: 'from_farm_id'

    # Reproduction
    has_many :seasons, class_name: 'KepplerReproduction::Season'
    has_many :milk_tanks, class_name: "KepplerReproduction::MilkTank"
    has_many :milk_weights, class_name: "KepplerReproduction::MilkWeight"

    has_one :milk_lot, class_name: 'KepplerFarm::StrategicLot'

    has_many :inventories, class_name: 'KepplerCattle::Inventory'

    has_many :tasks

    has_many :grounds, class_name: 'KepplerFarm::Ground'

    # accepts_nested_attributes_for :cows

    def self.index_attributes
      %i[logo title photos strategic_lots]
    end

    def photos
      KepplerFarm::Photo.where(farm_id: id)
    end

    def none_cover?
      photos.where(cover: true).size.zero?
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
      PublicActivity::Activity.includes(:trackable, :owner).where(trackable_id: ids)
        .or(PublicActivity::Activity.includes(:trackable, :owner).where(recipient_id: ids))
    end

    def possible_mothers
      ids =
        cows.where(gender: 'female')
          .select { |x| %w[1 2].include?(x.typology&.counter.to_s) }
          .map(&:id)
      cows.where(id: ids).order(:serie_number)
    end

    def possible_fathers
      ids =
        cows.includes(:male)
          .where(gender: 'male')
          .select { |x| x.male&.reproductive }
          .map(&:id)
      cows.where(id: ids).order(:serie_number)
    end

    def possible_mothers_select2
      possible_mothers.map do |x|
        [x.serie_number + ("(#{x&.short_name}) - #{x&.typology_name}" unless x&.short_name.blank?).to_s, x.id]
      end
    end

    def possible_fathers_select2
      possible_fathers
        .map { |x| [x.serie_number + ("(#{x&.short_name})" unless x&.short_name.blank?).to_s, "#{x.class.to_s}, #{x.id}"] }
        .concat(KepplerCattle::Insemination.order(:serie_number).map {
          |x| [x.serie_number + ("(#{x&.short_name}) - Pajuela" unless x&.short_name.blank?).to_s, "#{x.class.to_s}, #{x.id}"]
        })
    end

    def total_milking_days
      days_to_service + days_to_pregnancy + days_to_dry + days_to_rest
    end
  end
end
