# This migration comes from keppler_cattle (originally 20190128233142)
class CreateKepplerCattleTransferences < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_transferences do |t|
      t.jsonb :cattle
      t.integer :from_farm_id
      t.integer :to_farm_id
      t.text :description
      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
