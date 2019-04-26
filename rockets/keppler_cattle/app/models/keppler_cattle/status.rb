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
        date: params.dig(:status, :date) || Date.today,
        months: params.dig(:status, :months),
        user: responsable,
        user_id: responsable&.id,
        observations: params.dig(:status, :observations) || '',
        insemination_id: params.dig(:status, :insemination_id),
        insemination_quantity: params.dig(:status, :insemination_quant).to_i,

        successfully: params.dig(:status, :successfully),
        twins: params.dig(:status, :twins),
      )
      this_status.cow_id ||= params.dig(:status, :cow_id) || hash[:cow_id]
      this_status
    end

    private

    def set_date
      date ||= Date.today
    end
  end
end
