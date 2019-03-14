# This migration comes from keppler_cattle (originally 20190116155658)
class CreateKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_cows do |t|
      t.string :image
      t.string :serie_number
      t.string :short_name
      t.string :gender
      t.date :birthdate
      t.string :coat_color
      t.string :nose_color
      t.string :tassel_color
      t.string :provenance
      t.text :observations

      t.integer :species_id, foreign_key: true
      t.integer :race_id, foreign_key: true

      t.integer :mother_id, foreign_key: true

      t.string :father_type
      t.integer :father_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_cows, :species_id
    add_index :keppler_cattle_cows, :race_id
    add_index :keppler_cattle_cows, :mother_id
    add_index :keppler_cattle_cows, :father_id
  end
end
