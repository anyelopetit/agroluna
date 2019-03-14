# This migration comes from keppler_cattle (originally 20190201152143)
class CreateKepplerCattleSpecies < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_species do |t|
      t.string :name
      t.string :abbreviation

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
