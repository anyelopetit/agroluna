# frozen_string_literal: true

module KepplerReproduction
  # Season Model
  class Season < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :farm, class_name: 'KepplerFarm::Farm', foreign_key: 'farm_id'
    has_many :season_cows, class_name: 'KepplerReproduction::SeasonCow', inverse_of: :season
    has_many :cows, -> (season) {
      # joins(locations: :farm, seasons: :season_cows).where('keppler_cattle_locations.farm_id = ? AND keppler_cattle_locations.id = (SELECT MAX(keppler_cattle_locations.id) FROM keppler_cattle_locations) AND keppler_reproduction_seasons.id = ? AND keppler_reproduction_seasons.id = (SELECT MAX(keppler_reproduction_seasons.id) FROM keppler_reproduction_seasons)', $request&.params&.dig('farm_id'), season.id)
      ids = select do |cow|
        cow.locations&.last&.farm_id == $request&.params&.dig('farm_id').to_i && cow.seasons&.last&.id == season.id
      end.pluck(:id)
      where(id: ids)
    }, class_name: 'KepplerCattle::Cow', through: :season_cows
    # end
    has_many :statuses, ->(season){ where(season_id: season.id) }, class_name: 'KepplerCattle::Status', through: :cows
    has_many :users, -> { distinct }, class_name: 'KepplerFarm::Responsable', through: :statuses
    has_many :inefectivities, -> { distinct }, class_name: 'KepplerReproduction::Inefectivity', through: :users

    validates_presence_of :farm_id, :start_date, :duration_days, on: :create, message: "can't be blank"

    def self.index_attributes
      %i[name]
    end

    def self.farm
      KepplerFarm::Farm.find_by(id: ($request.params[:farm_id]))
    end

    def duration_days
      if attribute_names.include?('duration_days')
        super
      else
        distance_of_time_in_days(start_date, finish_date, include_seconds = false)
      end
    end

    def distance_of_time_in_days(from_time, to_time = 0, include_seconds = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      (((to_time - from_time).abs)/86400).round + 1
    end

    def finish_date
      start_date + duration_days.to_i.days
    end

    def duration_dates
      days = []
      duration_days.to_i.times { |time| days.push(start_date + time) }
      days
    end

    # def total_days
    #   duration_days.to_i.zero? || (finish_date.days - start_date.days)
    # end

    def month_days_count(month)
      duration_dates.select { |x| x.strftime("%m").eql?(month) }.size
    end

    def months_on_season
      duration_dates.map { |x| x.strftime("%m") }.uniq
    end

    def all_months
      %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre]
    end

    def cicle_colors
      ['#54c6f9', '#2ecaac', '#ff6252']
    end

    def self.types
      [
        [I18n.t('activerecord.attributes.natural'), 0],
        [I18n.t('activerecord.attributes.controlled'), 1]
      ]
    end

    def type_name
      self.class.types[season_type.to_i].first
    end

    def type_id
      self.class.types[season_type.to_i].last
    end

    def strategic_lots
      ids = cows.map { |c| c.location.strategic_lot_id }
      farm.strategic_lots.where(id: ids)
    end

    def pregnants
      statuses.where(status_type: 'Pregnancy')
    end
  end
end
