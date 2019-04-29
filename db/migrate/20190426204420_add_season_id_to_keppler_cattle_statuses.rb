class AddSeasonIdToKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_statuses, :season_id, :integer
  end
end
