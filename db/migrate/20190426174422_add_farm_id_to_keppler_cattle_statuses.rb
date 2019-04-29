class AddFarmIdToKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_statuses, :farm_id, :integer
  end
end
