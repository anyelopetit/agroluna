module KepplerReproduction
  class CheeseType < ApplicationRecord
    validates_presence_of :name, :liters_needed
  end
end