# This migration comes from keppler_cattle (originally 20191020220722)
class CreateKepplerCattleInventories < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_inventories do |t|
      t.integer :farm_id
      t.string :name
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
