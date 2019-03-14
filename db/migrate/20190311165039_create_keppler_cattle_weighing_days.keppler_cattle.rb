# This migration comes from keppler_cattle (originally 20190201171124)
class CreateKepplerCattleWeighingDays < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_weighing_days do |t|
      t.string :name
      t.integer :min_days
      t.integer :specific_day
      t.integer :max_days

      t.integer :species_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_weighing_days, :species_id
  end
end
