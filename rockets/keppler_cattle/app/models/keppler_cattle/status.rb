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

    def self.index_attributes
      %i[]
    end

    def user_name
      user.try(:name)
    end

    def user_name=(name)
      self.user = KepplerFarm::Responsable.find_or_create_by_name(name) if name.present?
    end

    private

    def set_date
      date ||= Date.today
    end
  end
end
