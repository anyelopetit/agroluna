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

    # belongs_to :mother, class_name: 'KepplerCattle::Cow', foreign_key: :mother_id, optional: true

    has_many :locations, class_name: 'KepplerCattle::Location', dependent: :destroy
    has_many :strategic_lots, class_name: "KepplerFarm::StrategicLot", through: :locations

    has_many :weights, class_name: 'KepplerCattle::Weight', dependent: :destroy
    has_many :cow_activities, class_name: 'KepplerCattle::Activity', dependent: :destroy
    has_many :cow_typologies, class_name: 'KepplerCattle::CowTypology', dependent: :destroy
    has_many :typologies, class_name: 'KepplerCattle::Typology', through: :cow_typologies

    has_many :statuses, class_name: 'KepplerCattle::Status', dependent: :destroy
    has_many :aborts, class_name: 'KepplerCattle::Abort', dependent: :destroy

    has_many :season_cows, class_name: 'KepplerReproduction::SeasonCow', dependent: :destroy
    has_many :seasons, class_name: 'KepplerReproduction::Season', through: :season_cows

    has_many :milk_weights, class_name: 'KepplerReproduction::MilkWeight', dependent: :destroy

    has_many :medical_histories, class_name: 'KepplerCattle::MedicalHistory', dependent: :destroy

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

    def season
      season_cows&.last&.season
    end

    def medical_history
      medical_histories.last
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

    def status_name
      statuses.last&.status_type
    end

    def status_name_es
      this_status =
        if ['Nil', nil].include?(status_name)
          'Vacía'
        elsif ['Zeal'].include?(status_name)
          'En Celo'
        elsif ['Service'].include?(status_name)
          'Inseminada'
        elsif ['Pregnancy'].include?(status_name)
          'Preñada'
        elsif ['Birth'].include?(status_name)
          'Parida'
        elsif ['Dry'].include?(status_name)
          'En secado'
        end
      "#{this_status}#{' Lactando' if milking}" if gender?('female') && [1, 2].include?(typology.counter.to_i)
    end

    def typology_counter_count
      case typology&.counter&.to_i
      when 1
        statuses.where(status_type: 'Service').size
      when 2
        sons.size
      else
        nil
      end
    end

    def typology_name
      "#{typology&.name} #{typology_counter_count} #{status_name_es}".titleize
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
      if father_type
        ft = father_type&.classify.constantize
        ft&.find_by(id: father_id)
      end
    end

    def sons
      KepplerCattle::Cow.where(mother_id: id).or(
        KepplerCattle::Cow.where(father_id: id)
      )
    end

    def self.babies
      all.map { |c| c.sons.select { |s| s.typology.min_age < 210 } }.flatten
    end

    def self.weight_average(cows)
      cows.map { |cow| cow.weight&.weight&.to_f }
        .inject { |sum, weight| sum + weight } / cows.size
    end

    def self.where_status(status_name, season_id = nil)
      if status_name.is_a?(Array)
        ids = select { |c| status_name.include?(c.status&.status_type) }.pluck(:id)
        where(id: ids)
      else
        # includes(:statuses).where(keppler_cattle_statuses: { status_type: status_name })
        select { |c| c.status_name == status_name }
        # ids = select { |c| status_name.eql?(c.status&.status_type) }.pluck(:id)
        # where(id: ids)
      end
    end

    def self.to_next_palpation(season_id)
      ids = includes(:statuses).where(
        keppler_cattle_statuses: {
          status_type: 'Service', season_id: season_id
        }
      ).select { |cow| Date.today > (cow.status.date + 45.days) }.pluck(:id)
      where(id: ids)
    end

    def sons_weight_average
      total_weights = 0
      sons_count = 0
      sons&.each_with_index do |son, index|
        total_weights += son&.weight&.weight
        sons_count += 1
      end
      sons_count.zero? ? 0 : total_weights / sons_count
    end

    def strategic_lot
      strategic_lots.last
    end

    def self.actives
      cows = select do |cow|
        (cow&.locations.pluck(:farm_id).include?(farm&.id) && cow&.location&.farm_id == farm&.id) &&
        cow&.activity&.active
      end
      active_ids = cows.pluck(:id).uniq
      where(id: active_ids)
    end

    def self.inactives
      cows = select do |cow|
        (cow&.locations.pluck(:farm_id).include?(farm&.id) && cow&.location&.farm_id != farm&.id) ||
        !cow&.activity&.active
      end
      inactive_ids = cows.pluck(:id).uniq
      includes(:locations).where(id: inactive_ids)
    end

    def active?
      # puts "############ FINCA #{farm.id} ######################"
      activity&.active # locations.pluck(:farm_id).include?(farm&.id) && location&.farm_id == farm&.id &&
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

    def self.where_milking
      where(milking: true)
    end

    def last_milk_weights
      return milk_weights if milking_date.blank?
      milk_weights.where("keppler_reproduction_milk_weights.created_at >= ?", milking_date)
    end

    def morning_liters
      last_milk_weights.sum(:morning_liters)
    end

    def evening_liters
      last_milk_weights.sum(:evening_liters)
    end

    def total_liters
      last_milk_weights.sum { |x| x.morning_liters + x.evening_liters }
    end

    def self.in_this_process(process)
      select { |x| x.status_name == process.camelcase }
    end

    def self.total_season_cows(strategic_lot)
      includes(:race, :locations)
        .where(
          gender: 'female',
          keppler_cattle_locations: { strategic_lot_id: strategic_lot.id }
        )
    end

    def self.total_season_bulls(strategic_lot)
      includes(:race, :season_cows)
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
