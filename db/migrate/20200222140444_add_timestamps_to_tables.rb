class AddTimestampsToTables < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :keppler_cattle_inventories, null: false, default: DateTime.current
    add_timestamps :keppler_cattle_inventory_cows, null: false, default: DateTime.current
    add_timestamps :keppler_cattle_medical_histories, null: false, default: DateTime.current
  end
end
