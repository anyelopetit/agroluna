# frozen_string_literal: true

module KepplerCattle
  # Cow Model
  class Cow < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    mount_uploader :image, AttachmentUploader
    acts_as_list
    acts_as_paranoid

    has_many :statuses, dependent: :destroy

    validates_presence_of :birthdate, :serie_number
    validates_uniqueness_of :serie_number

    def self.index_attributes
      %i[serie_number image short_name provenance]
    end

    def farm
      KepplerFarm::Farm.find_by(id: status.farm_id)
    end

    def race
      KepplerCattle::Race.find_by(id: race_id)
    end

    def species
      race.species
    end

    def self.genders
      ['female', 'male']
    end

    def self.colors
      ['No Registrado',
      'Cenizo',
      'Pardo',
      'Encerado',
      'Rojo',
      'Amarillo',
      'Pinto',
      'Blanco',
      'Negro',
      'Colorado']
    end

    def possible_typologies
      KepplerCattle::Typology
        .where(gender: gender)
        .or(
          KepplerCattle::Typology
          .where(species_id: species_id)
        )
    end

    def status
      statuses.last
    end

    def weight
      status.weight
    end

    def gender?(g)
      gender.eql?(g)
    end

    def self.posible_mothers
      select { |x| x.gender?('female') }
      .map { |x| [x.serie_number + (" (#{x&.short_name})" unless x&.short_name.blank?).to_s, x.id] }
    end

    def self.posible_fathers
      select { |x| x.gender?('male') }
      .map { |x| [x.serie_number + (" (#{x&.short_name})" unless x&.short_name.blank?).to_s, x.id] }
    end

    def mother
      KepplerCattle::Cow.find_by(id: mother_id) if mother_id
    end

    def father
      KepplerCattle::Cow.find_by(id: father_id) if father_id
    end

    def strategic_lot
      KepplerFarm::StrategicLot.find_by(id: status.strategic_lot_id)
    end

    def self.actives(farm)
      order(position: :desc).select { |x| x.status.farm_id.eql?(farm.id) unless x.status.blank? } if farm
    end

    def self.inactives(farm)
      order(position: :desc).select { |x| x.status.farm_id.eql?(farm.id)  unless x.status.blank? } if farm
    end

    def years 
      now = Time.now.utc.to_date 
      now.year - birthdate.year - (birthdate.to_date.change(:year => now.year) > now.year ? 1 : 0) 
    end 

    def months
      now = Time.now.utc.to_date 
      now.month >= birthdate.month ? (now.month - birthdate.month) : (12 - (birthdate.month - now.month))
    end

    def days
      now = Time.now.utc.to_date 
      days_count = 0
      # Suma de los años completos que han pasado x 365
      for y in birthdate.year+1..now.year-1
        for m in 01..12
          days_count += Time.days_in_month(m, y)
        end
      end
      # Suma desde el mes que naciste hasta finalizar ese año
      for m in birthdate.month..12
        days_count += Time.days_in_month(m, birthdate.year)
      end
      # Suma desde el primero de enero hasta un mes antes de ahora
      for m in 1..now.month-1
        days_count += Time.days_in_month(m, now.year)
      end
      # Suma o resta de los días del mes actual con tu día de nacimiento
      if birthdate.day > now.day
        days_count -= (birthdate.day - now.day)
      else
        days_count += (now.day - birthdate.day)
      end
    end
  end
end
