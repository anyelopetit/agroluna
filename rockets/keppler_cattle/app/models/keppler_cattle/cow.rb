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

    # validates_presence_of :birthdate, :serie_number

    def self.index_attributes
      %i[serie_number image short_name provenance]
    end

    def self.species
      ['bovine', 'goat']
    end

    def self.genders
      ['female', 'male']
    end

    def self.races
      ['raza 1', 'raza 2', 'raza 3']
    end

    def self.provenance
      ['provenance1', 'provenance2', 'provenance3']
    end

    def gender?(g)
      gender.eql?(g)
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
  end
end
