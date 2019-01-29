module KepplerCattle
  class Assignment < ApplicationRecord
    belongs_to :strategic_lot, class_name: 'KepplerFarm::StrategicLot'
    belongs_to :cow, class_name: 'KepplerCattle::Cow'

    def exists?
      Assignment.where(cow_id: cow_id, strategic_lot_id: strategic_lot_id).count > 0
    end

    def validate_cow
      none_assign = Assignment.where(cow_id: cow_id, strategic_lot_id: strategic_lot_id).count == 0
      #is_same_lot = KepplerCattle::Cow.find(cow_id).status.strategic_lot_id.eql?(strategic_lot_id)
      uniq_cow_in_lots = KepplerFarm::StrategicLot.select { |x| x.cows.find(cow_id) }.count == 1
      
      none_assign #&& uniq_cow_in_lots
    end
  end
end
