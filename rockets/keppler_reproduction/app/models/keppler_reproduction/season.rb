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

    has_many :season_cows, class_name: 'KepplerReproduction::SeasonCow'
    has_many :cows, class_name: 'KepplerCattle::Cow', through: :season_cows
    has_many :statuses, ->(season){ where(season_id: season.id) }, class_name: 'KepplerCattle::Status', through: :cows
    has_many :users, -> { distinct }, class_name: 'KepplerFarm::Responsable', through: :statuses
    has_many :inefectivities, -> { distinct }, class_name: 'KepplerReproduction::Inefectivity', through: :users

    has_many :cicles, class_name: 'KepplerReproduction::Cicle'

    validates_presence_of :farm_id, :start_date, :finish_date, on: :create, message: "can't be blank"

    def self.index_attributes
      %i[name]
    end

    def duration_days
      if finish_date.blank? && !cicles.blank?
        days = 0
        cicles.map { |x| days += x.days_count }
        days
      else
        distance_of_time_in_days(start_date, finish_date, include_seconds = false)
      end
    end

    def distance_of_time_in_days(from_time, to_time = 0, include_seconds = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      (((to_time - from_time).abs)/86400).round + 1
    end

    def duration_dates
      days = []
      duration_days.times { |time| days.push(start_date + time) }
      days
    end

    def month_days_count(month)
      duration_dates.select { |x| x.strftime("%m").eql?(month) }.count
    end

    def months_on_season
      duration_dates.map { |x| x.strftime("%m") }.uniq
    end

    def all_months
      %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octumbre Noviembre Diciembre]
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
      cows.select {|c| c.status&.status_type&.eql?('Pregnancy') }
    end
  end
end
