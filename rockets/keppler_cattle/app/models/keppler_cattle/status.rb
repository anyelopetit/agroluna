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
    belongs_to :user, class_name: 'KepplerFarm::Responsable', foreign_key: 'user_id'

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
      self.user = KepplerFarm::Responsable.find_or_create_by_name(name) if name.present?
    end

    def self.new_status(params, *cow_id)
      responsable = KepplerFarm::Responsable.find_or_create_by(
        name: params[:status][:user_name]
      )
      new(
        status_type: params[:status][:type],
        cow_id: cow_id[0] || params[:status][:cow_id].to_i,
        date: params[:status][:date] || Date.today,
        months: params[:status][:months] || nil,
        user: responsable,
        user_id: responsable&.id,
        observations: params[:status][:observations] || '',
        insemination_id: params[:status][:insemination_id] || nil,
        insemination_quantity: params[:status][:insemination_quant].to_i || nil,

        successfully: params[:status][:successfully] || nil,
        twins: params[:status][:twins] || nil,
      )
    end

    private

    def set_date
      date ||= Date.today
    end
  end
end
