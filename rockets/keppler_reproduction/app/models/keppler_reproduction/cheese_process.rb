module KepplerReproduction
  class CheeseProcess < ApplicationRecord
    validates_presence_of :date, :received_liters, :processed_liters, :farm_id, :cheese_type_id, :real_cheese
    belongs_to :responsable, class_name: 'KepplerFarm::Responsable', foreign_key: 'responsable_id', optional: true
  end
end