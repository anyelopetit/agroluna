class AddStrategicLotIdToSeasonCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_reproduction_season_cows, :strategic_lot_id, :integer
  end
end
