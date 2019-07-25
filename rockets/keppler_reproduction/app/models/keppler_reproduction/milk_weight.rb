module KepplerReproduction
  class MilkWeight < ApplicationRecord
    validates_presence_of :farm_id, :cow_id, :date
  end
end