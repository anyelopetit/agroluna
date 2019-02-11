# This migration comes from keppler_cattle (originally 20190206170234)
class CreateKepplerCattleInseminations < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_inseminations do |t|
      t.string :serie_number
      t.string :short_name
      t.string :coat_color
      t.string :nose_color
      t.string :tassel_color
      t.string :provenance

      t.date :birthdate
      t.date :used

      t.text :observations

      t.integer :position
      t.datetime :deleted_at

      t.integer :farm_id
      t.integer :species_id
      t.integer :race_id
      
      t.integer :mother_id
      t.integer :father_id

      t.timestamps null: false
    end
  end
end
