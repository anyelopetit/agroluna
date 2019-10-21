# This migration comes from keppler_cattle (originally 20191021002325)
class CreateKepplerCattleInventoryCows < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_inventory_cows do |t|
      t.string :serie_number
      t.boolean :found
      t.integer :inventory_id
      t.integer :cow_id
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
