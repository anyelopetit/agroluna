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
    has_one :species, through: :race
    has_one :race
    has_one :typology, through: :status

    validates_presence_of :birthdate, :serie_number
    validates_uniqueness_of :serie_number

    def self.index_attributes
      %i[serie_number short_name race_name typology_name gender]
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

    def sons
      KepplerCattle::Cow.where(mother_id: id).or(
        KepplerCattle::Cow.where(father_id: id)
      )
    end


    def strategic_lot
      assignment_lot = KepplerCattle::Assignment.find_by(cow_id: id)&.strategic_lot_id
      KepplerFarm::StrategicLot.find_by(id: assignment_lot) if assignment_lot
    end

    def self.actives
      cows = select do |cow|
        cow&.status&.farm_id == farm.id &&
        !cow&.status&.dead && !cow&.status&.deathdate
      end
      active_ids = cows.pluck(:id).uniq
      where(id: active_ids)
    end

    def self.inactives
      cows = select do |cow|
        (cow&.statuses&.map(&:farm_id).include?(farm.id) &&
        cow&.status&.farm_id != farm.id) || 
        cow&.status&.dead || cow&.status&.deathdate
      end
      inactive_ids = cows.pluck(:id).uniq
      where(id: inactive_ids)
    end
  end
end
