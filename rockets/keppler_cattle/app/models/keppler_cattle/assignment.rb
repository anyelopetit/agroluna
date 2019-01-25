module KepplerCattle
  class Assignment < ApplicationRecord
    belongs_to :strategic_lot, class_name: 'KepplerFarm::StrategicLot'
    belongs_to :cow, class_name: 'KepplerCattle::Cow'

    def exists?
      Assignment.where(cow_id: cow_id, strategic_lot_id: strategic_lot_id).count > 0
    end
  end
end
