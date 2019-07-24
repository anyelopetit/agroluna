module KepplerReproduction
  class MilkTank < ApplicationRecord
    validates_presence_of :farm_id, :name, :milk_capacity
  end
end