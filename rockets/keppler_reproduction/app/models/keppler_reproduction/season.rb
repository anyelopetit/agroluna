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

    has_many :cicles, class_name: 'KepplerReproduction::Cicle'

    validates_presence_of :farm_id, on: :create, message: "can't be blank"

    def self.index_attributes
      %i[name]
    end

    def duration_days
      days = 0
      cicles.map { |x| days += x.days_count }
      days
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
        [I18n.t('activerecord.attributes.insemination'), 0],
        [I18n.t('activerecord.attributes.unibull'), 1],
        [I18n.t('activerecord.attributes.multibull'), 2]
      ]
    end

    def type_name
      self.class.types[season_type.to_i].first
    end

    def type_id
      self.class.types[season_type.to_i].last
    end
  end
end
