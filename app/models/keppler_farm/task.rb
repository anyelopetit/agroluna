class KepplerFarm::Task < ApplicationRecord
  belongs_to :farm, class_name: 'KepplerFarm::Farm'
  belongs_to :user
end
