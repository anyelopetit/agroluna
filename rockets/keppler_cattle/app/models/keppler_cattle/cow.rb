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
    include KepplerCattle::Concerns::CreateCowTypology
    mount_uploader :image, AttachmentUploader
    acts_as_list
    acts_as_paranoid
    # after_save :create_first_location
    # after_save :create_first_activity
    # after_save :create_typology

    belongs_to :race, class_name: 'KepplerCattle::Race'
    belongs_to :species, class_name: 'KepplerCattle::Species'

    has_one :male, class_name: 'KepplerCattle::Male', dependent: :destroy

    has_many :locations, class_name: 'KepplerCattle::Location', dependent: :destroy
    has_many :strategic_lots, class_name: "KepplerFarm::StrategicLot", through: :locations

    has_many :weights, class_name: 'KepplerCattle::Weight', dependent: :destroy
    has_many :cow_activities, class_name: 'KepplerCattle::Activity', dependent: :destroy
    has_many :cow_typologies, class_name: 'KepplerCattle::CowTypology', dependent: :destroy
    has_many :typologies, class_name: 'KepplerCattle::Typology', through: :cow_typologies, dependent: :destroy

    has_many :statuses, class_name: 'KepplerCattle::Status', dependent: :destroy

    has_many :season_cows, class_name: 'KepplerReproduction::SeasonCow', dependent: :destroy
    has_many :seasons, class_name: 'KepplerReproduction::Season', through: :season_cows

    validates_presence_of :birthdate, :serie_number, :species_id, :race_id
    validates_uniqueness_of :serie_number

    def self.index_attributes
      %i[serie_number short_name race_id typology_name gender]
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

    def status
      statuses.last
    end

    def typology_counter_count
      case typology&.counter&.to_i
      when 1
        statuses.where(status_type: 'Service').count
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
      mother_typologies_ids = KepplerCattle::Typology.where(counter: ['1', '2']).pluck(:id)
      cows_ids = select { |x| mother_typologies_ids.include?(x.typology&.id) }.pluck(:id)
      where(id: cows_ids)
    end

    def self.possible_fathers
      includes(:male)
        .where(keppler_cattle_males: {reproductive: true})
        # .select { |x| x.male.reproductive }
        # .order(:serie_number)
    end

    def self.possible_mothers_select2
      possible_mothers.map do |x|
        [x.serie_number + ("(#{x&.short_name}) - #{x&.typology_name}" unless x&.short_name.blank?).to_s, x.id]
      end
    end

    def self.possible_fathers_select2
      possible_fathers
        .map { |x| [x.serie_number + ("(#{x&.short_name})" unless x&.short_name.blank?).to_s, "#{x.class.to_s}, #{x.id}"] }
        .concat(KepplerCattle::Insemination.order(:serie_number).map { 
          |x| [x.serie_number + ("(#{x&.short_name}) - Pajuela" unless x&.short_name.blank?).to_s, "#{x.class.to_s}, #{x.id}"] 
        }) 
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


    def self.weight_average(cows)
      cows.map { |cow| cow.weight&.weight&.to_f }
        .inject { |sum, weight| sum + weight }
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
      includes(:locations).where(id: inactive_ids)
    end

    def self.reproductive_males(season)
      where(gender: 'male')
        .select do |c|
          !c.season_cows.pluck(:season_id).include?(season.id) ||
          c.season_cows.blank?
        end
    end

    def self.out_of_lot(strategic_lot_id)
      ids =
        select { |c| !c.location.strategic_lot_id.eql?(strategic_lot_id) }
          .pluck(:id)
      where(id: ids)
    end

    def self.total_season_cows(strategic_lot)
      includes(:race).includes(:locations)
        .where(gender: 'female')
        .where(keppler_cattle_locations: { strategic_lot_id: strategic_lot.id })
    end

    def self.total_season_bulls(strategic_lot)
      includes(:race).includes(:season_cows)
        .where(gender: 'male')
        .where(keppler_reproduction_season_cows: {
          strategic_lot_id: strategic_lot.id
        })
    end

    def self.type_is(types_array)
      select do |c|
        types_array.include?(c.status&.status_type)
      end
    end

    def create_first_location(hash)
      locations.create!(
        cow_id: id,
        user_id: hash[:user_id],
        farm_id: hash[:farm_id],
        strategic_lot_id: hash[:strategic_lot_id]
      )
    end

    def create_first_activity(hash)
      cow_activities.create!(
        cow_id: id,
        user_id: hash[:user_id],
        active: true
      )
    end

    def create_first_weight(params, hash)
      weights.create!(
        weight: params.dig(:weight) || hash.dig(:weight),
        gained_weight: params.dig(:gained_weight) || hash.dig(:gained_weight),
        average_weight: params.dig(:average_weight) || hash.dig(:average_weight),
        corporal_condition_id: params.dig(:corporal_condition_id) || hash.dig(:corporal_condition_id),
        cow_id: id,
        user_id: hash.dig(:user_id),
        user: hash.dig(:user)
      )
    end
  end
end
