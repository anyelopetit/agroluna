# This migration comes from keppler_cattle (originally 20190206170234)
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
      t.integer :quantity

      t.date :birthdate
      # t.date :used_date

      t.text :observations

      t.integer :farm_id
      t.integer :species_id
      t.integer :race_id
      t.integer :typology_id
      
      t.integer :mother_id
      t.integer :father_id

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_inseminations, :farm_id
    add_index :keppler_cattle_inseminations, :species_id
    add_index :keppler_cattle_inseminations, :race_id
    add_index :keppler_cattle_inseminations, :typology_id
    
    add_index :keppler_cattle_inseminations, :mother_id
    add_index :keppler_cattle_inseminations, :father_id

  end
end
