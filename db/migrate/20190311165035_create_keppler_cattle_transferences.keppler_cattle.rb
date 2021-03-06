# This migration comes from keppler_cattle (originally 20190128233142)
# This migration comes from keppler_cattle (originally 20190128233142)
class CreateKepplerCattleTransferences < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_transferences do |t|
      t.jsonb :cattle
      t.string :reason

      t.integer :from_farm_id, foreign_key: true
      t.integer :to_farm_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_transferences, :from_farm_id
    add_index :keppler_cattle_transferences, :to_farm_id
  end
end
