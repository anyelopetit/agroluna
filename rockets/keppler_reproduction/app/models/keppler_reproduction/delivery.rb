module KepplerReproduction
  class Delivery < ApplicationRecord
    validates_presence_of :farm_id, :date, :liters, :destination
  end
end