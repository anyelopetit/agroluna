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
    after_save :create_first_location
    after_save :create_first_activity
    # after_save :create_typology

    belongs_to :race, class_name: 'KepplerCattle::Race', foreign_key: 'race_id'
    belongs_to :species, class_name: 'KepplerCattle::Species', foreign_key: 'species_id'

    has_one :male, class_name: 'KepplerCattle::Male', dependent: :destroy

    has_many :locations, class_name: 'KepplerCattle::Location', dependent: :destroy
    has_many :strategic_lots, class_name: "KepplerFarm::StrategicLot", through: :locations

    has_many :weights, class_name: 'KepplerCattle::Weight', dependent: :destroy
    has_many :cow_activities, class_name: 'KepplerCattle::Activity', dependent: :destroy
    has_many :cow_typologies, class_name: 'KepplerCattle::CowTypology', dependent: :destroy
    has_many :typologies, class_name: 'KepplerCattle::Typology', through: :cow_typologies, dependent: :destroy

    has_many :statuses, class_name: 'KepplerCattle::Status', dependent: :destroy

    validates_presence_of :birthdate, :serie_number, :species_id, :race_id
    validates_uniqueness_of :serie_number

    def self.index_attributes
      %i[serie_number short_name race_name typology_name gender]
    end

    def farm
      KepplerFarm::Farm.find_by(id: (location&.farm_id || $request.params[:farm_id]))
    end

    def self.farm
      KepplerFarm::Farm.find_by(id: $request.params[:farm_id])
    end

    # def species
    #   KepplerCattle::Species.find_by(id: species_id)
    # end

    # def race
    #   KepplerCattle::Race.find_by(id: race_id)
    # end

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

    def location
      locations.last
    end

    def weight
      weights.last
    end

    def activity
      cow_activities.last
    end

    def typology
      cow_typologies.last&.typology
    end

    def typology_counter_count
      case typology&.counter&.to_i
      when 1
        0 # TOCHANGE
      when 2
        sons.count
      else
        nil
      end
    end

    def typology_name
      "#{typology&.name} #{typology_counter_count}"
    end

    def gender?(g)
      gender.eql?(g)
    end

    def possible_typologies
      species.typologies.where(gender: gender)
    end

    def self.possible_mothers
      includes(:typologies)
        .where(gender: 'female')
        .where(keppler_cattle_typologies: {counter: ['1', '2']}).distinct
        # .order(:serie_number)
    end

    def self.possible_fathers
      includes(:male)
        .where(keppler_cattle_males: {reproductive: true})
        .select { |x| x.males.last.reproductive }
        # .order(:serie_number)
      
    end

    def mother
      KepplerCattle::Cow.find_by(id: mother_id) if mother_id
    end

    def father
      ft = father_type&.classify.constantize if father_type
      ft&.find_by(id: father_id)
    end

    def sons
      KepplerCattle::Cow.where(mother_id: id).or(
        KepplerCattle::Cow.where(father_id: id)
      )
    end

    def sons_weight_average
      total_weights = 0
      sons_count = 0
      sons&.each_with_index do |son, index|
        total_weights += son&.weight&.weight
        sons_count += 1
      end
      total_weights / sons_count
    end

    def strategic_lot
      strategic_lots.last
    end

    def self.actives
      cows = select do |cow|
        # cow&.location&.farm_id == farm&.id &&
        cow&.activity&.active
      end
      active_ids = cows.pluck(:id).uniq
      where(id: active_ids)
    end

    def self.inactives
      cows = select do |cow|
        (cow&.locations.pluck(:farm_id).include?(farm&.id) &&
        cow&.location&.farm_id != farm&.id) || 
        !cow&.activity&.active
      end
      inactive_ids = cows.pluck(:id).uniq
      where(id: inactive_ids)
    end

    private

    def create_first_location
      locations.create(
        # user_id: current_user,
        cow_id: id,
        farm_id: $request.blank? ? [1,2].sample : $request.params[:farm_id]
      )
    end

    def create_first_activity
      cow_activities.create(
        # user_id: current_user,
        cow_id: id,
        active: true
      )
    end
  end
end
