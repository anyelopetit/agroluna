# This migration comes from keppler_cattle (originally 20190206170234)
class CreateKepplerCattleInseminations < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_inseminations do |t|
      t.string :serie_number
      t.string :short_name
      t.string :corporal_condition
      t.string :coat_color
      t.string :nose_color
      t.string :tassel_color
      t.string :provenance

      t.date :birthdate
      t.date :used

      t.text :observations

      t.integer :position
      t.datetime :deleted_at

      t.string :farm_id
      t.string :species_id
      t.string :race_id
      t.string :typology_id
      
      t.string :mother_id
      t.string :father_id

      t.timestamps null: false
    end
  end
end
