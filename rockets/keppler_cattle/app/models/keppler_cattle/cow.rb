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
    include KepplerCattle::Concerns::Ageable
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

    def self.farm
      KepplerFarm::Farm.find_by(id: $request.params[:farm_id])
    end

    def species
      KepplerCattle::Species.find_by(id: species_id)
    end

    def race
      KepplerCattle::Race.find_by(id: race_id)
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
        .where(species_id: species_id, gender: gender)
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

    def self.actives
      active_ids = farm.cows.select { |x| !x&.status&.deathdate }.pluck(:id).uniq
      where(id: active_ids)
    end

    def self.inactives
      inactive_ids = farm.cows.select { |x| x&.status&.deathdate }.pluck(:id).uniq
      where(id: inactive_ids)
    end
  end
end
