class AddInFarmToKepplerCattleInventoryCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_inventory_cows, :in_farm, :boolean
  end
end
