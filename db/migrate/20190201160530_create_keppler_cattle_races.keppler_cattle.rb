# This migration comes from keppler_cattle (originally 20190201160526)
class CreateKepplerCattleRaces < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_races do |t|
      t.string :name
      t.string :abbreviation
      t.text :description
      t.integer :position
      t.datetime :deleted_at

      t.integer :species_id, foreign_key: true

      t.timestamps null: false
    end
  end
end
