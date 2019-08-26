module KepplerReproduction
  class MilkWeight < ApplicationRecord
    belongs_to :farm, class_name: "KepplerFarm::Farm", foreign_key: "farm_id"
    belongs_to :cow, class_name: "KepplerCattle::Cow", foreign_key: "cow_id"

    validates_presence_of :farm_id, :cow_id, :date

    def self.in_month(month = Date.today.month)
      where("extract(month from created_at) < #{month}")
    end

    def total_liters
      (morning_liters.to_f + evening_liters.to_f).round(2)
    end

    def self.total_liters
      sum { |x| x.morning_liters + x.evening_liters }
    end

    def self.average_liters
      total_liters / size
    end
  end
end