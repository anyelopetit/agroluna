module KepplerReproduction
  class CheeseProcess < ApplicationRecord
    validates_presence_of :date, :received_liters, :processed_liters, :farm_id, :cheese_type_id
  end
end