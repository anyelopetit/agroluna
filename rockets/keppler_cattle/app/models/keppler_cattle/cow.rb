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

    def self.index_attributes
      %i[serie_number image short_name provenance]
    end

    def farm
      KepplerFarm::Farm.find(status.farm_id) if status
    end

    def self.species
      ['bovine', 'goat']
    end

    def self.genders
      ['female', 'male']
    end

    def self.races
      ['Mestizo Carora',
      'Mestizo Holstein',
      'Pardo Suizo Puro',
      'Mestizo Brahman',
      'Brahman',
      'No Registrado',
      'Senepol',
      'Mestizo Senepol',
      'Mestizo Carora Holstein',
      'Campolargo',
      'Campolargo2',
      'Brahaman',
      'Mestizo Brahman 5/8']
    end

    def self.provenance
      ['provenance1', 'provenance2', 'provenance3']
    end

    def self.colors
      ['Cenizo',
      'Pardo',
      'Encerado',
      'No Registrado',
      'Rojo',
      'Amarillo',
      'Pinto',
      'Blanco',
      'Negro',
      'Colorado']
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
      KepplerCattle::Cow.find(mother_id) if mother_id
    end

    def father
      KepplerCattle::Cow.find(father_id) if father_id
    end

    def self.actives(farm)
      order(position: :desc).select { |x| x.status.farm_id.eql?(farm.id) unless x.status.blank? } if farm
    end

    def self.inactives(farm)
      order(position: :desc).select { |x| x.status.farm_id.eql?(farm.id)  unless x.status.blank? } if farm
    end

    def years 
      now = Time.now.utc.to_date 
      now.year - birthdate.year - (birthdate.to_date.change(:year => now.year) > now ? 1 : 0) 
    end 

    def months
      now = Time.now.utc.to_date 
      now.month >= birthdate.month ? (now.month - birthdate.month) : (12 - (birthdate.month - now.month))
    end

    def days
      now = Time.now.utc.to_date 
      days_count = 0
      for y in birthdate.year+1..now.year
        for m in birthdate.month+1..now.month
          days_count += Time.days_in_month(m, y)
        end
      end
      last_month_to_end = 
        birthdate.month == now.month ? 0 : Time.days_in_month((now - 1.month).month, (now - 1.month).year) - birthdate.day
      days_count += now.day + last_month_to_end
    end

    def left_days
      days_list = [206, 210, 365, 540, 730]
      max_days = 999
      days_list.each do |d|
        left_days = (d - days < 999 && d - days > 0)
      end
      left_days
    end
  end
end
