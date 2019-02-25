# This migration comes from keppler_cattle (originally 20190116155658)
class CreateKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_cows do |t|
      t.string :serie_number
      t.string :image
      t.string :short_name
      t.string :gender
      t.date :birthdate
      t.string :coat_color
      t.string :nose_color
      t.string :tassel_color
      t.string :provenance
      t.text :observations
      t.integer :position
      t.datetime :deleted_at

      t.integer :species_id
      t.integer :race_id

      t.integer :mother_id

      # t.string :father_type
      t.integer :father_id

      t.timestamps
    end
  end
end
