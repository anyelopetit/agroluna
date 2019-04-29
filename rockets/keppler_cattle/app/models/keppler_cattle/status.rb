# frozen_string_literal: true

module KepplerCattle
  # Status Model
  class Status < ApplicationRecord
    include ActivityHistory
    include CloneRecord
    include Uploadable
    include Downloadable
    include Sortable
    include Searchable
    acts_as_list
    acts_as_paranoid

    belongs_to :cow, class_name: 'KepplerCattle::Cow', foreign_key: 'cow_id'
    belongs_to :user, class_name: 'KepplerFarm::Responsable', foreign_key: 'user_id', optional: true
    belongs_to :farm, class_name: 'KepplerFarm::Farm', foreign_key: 'farm_id', optional: true
    belongs_to :season, class_name: 'KepplerReproduction::Season', foreign_key: 'season_id', optional: true

    belongs_to :insemination, class_name: 'KepplerCattle::Insemination', optional: true

    before_save :set_date

    validates_presence_of :status_type, :date, :cow_id

    def self.index_attributes
      %i[]
    end

    def user_name
      user.try(:name)
    end

    def user_name=(name)
      self.user =
        KepplerFarm::Responsable.find_or_create_by_name(name) if name.present?
    end

    def self.new_status(params, hash = {})
      responsable = KepplerFarm::Responsable.find_or_create_by(
        name: params.dig(:status, :user_name)
      )
      this_status = new(
        status_type: params.dig(:status, :type) || hash[:status_type],
        season_id: hash[:season_id] || params.dig(:status, :season_id).to_i,
        date: params.dig(:status, :date) || Date.today,
        months: params.dig(:status, :months),
        user: responsable,
        user_id: responsable&.id,
        observations: params.dig(:status, :observations),
        insemination_id: params.dig(:status, :insemination_id),
        insemination_quantity: params.dig(:status, :insemination_quant),

        successfully: params.dig(:status, :successfully),
        twins: params.dig(:status, :twins),
      )
      season = KepplerReproduction::Season.find_by_id(this_status.season_id)
      cow = KepplerCattle::Cow.find_by_id(
        params.dig(:status, :cow_id) || hash[:cow_id]
      )
      if this_status.try(:farm_id)
        this_status.farm_id = hash[:farm_id] || params.dig(:farm_id).to_i
      end
      this_status.season_id ||= season.id
      this_status.cow_id ||= cow.id
      puts "************* season #{this_status.season_id} *************"
      self.create_inefectivity(cow, this_status, season)
      this_status
    end

    private

    def set_date
      date ||= Date.today
    end

    def self.create_inefectivity(cow, this_status, season)
      cow_is_pregnant = cow&.status&.status_type&.eql?('Pregnancy')
      this_is_birth = this_status&.status_type&.eql?('Birth')
      if cow_is_pregnant && !this_is_birth
        KepplerReproduction::Inefectivity.create(
          responsable_id: cow.status&.user_id,
          season_id: season.id,
          cow_id: cow.id
        )
      end
    end
  end
end
