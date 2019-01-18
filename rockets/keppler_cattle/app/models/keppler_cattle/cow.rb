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

    validates_presence_of :birthdate

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
      ['race1', 'race2', 'race3']
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
      now.month > birthdate.month ? (now.month - birthdate.month) : (12 - (birthdate.month - now.month))
    end
  end
end
