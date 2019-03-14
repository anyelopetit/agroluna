class CreateKepplerCattleCorporalConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_corporal_conditions do |t|
      t.string :name
      t.integer :number
      t.text :description

      t.integer :species_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_corporal_conditions, :species_id
  end
end
