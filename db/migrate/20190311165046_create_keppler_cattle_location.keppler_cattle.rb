# This migration comes from keppler_cattle (originally 20190311135714)
class CreateKepplerCattleLocation < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_locations do |t|
      t.text :observations

      t.integer :user_id#, foreign_key: true
      t.integer :cow_id, foreign_key: true
      t.integer :farm_id, foreign_key: true
      t.integer :strategic_lot_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    # add_index :keppler_cattle_locations, :user_id
    add_index :keppler_cattle_locations, :cow_id
    add_index :keppler_cattle_locations, :farm_id
    add_index :keppler_cattle_locations, :strategic_lot_id
  end
end
