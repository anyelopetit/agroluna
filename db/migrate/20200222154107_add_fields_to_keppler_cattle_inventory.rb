class AddFieldsToKepplerCattleInventory < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_inventories, :date, :date
    add_column :keppler_cattle_inventories, :closed_at, :date
  end
end
