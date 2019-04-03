module KepplerFarm
  class Assignment < ApplicationRecord
    belongs_to :user
    belongs_to :keppler_farm_farm, class_name: 'KepplerFarm::Farm'

    def exists?
      Assignment.where(user_id: user_id, keppler_farm_farm_id: keppler_farm_farm_id).exists?
    end
  end
end
