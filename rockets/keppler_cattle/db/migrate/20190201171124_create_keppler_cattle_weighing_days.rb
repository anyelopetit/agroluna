class CreateKepplerCattleWeighingDays < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_weighing_days do |t|
      t.string :name
      t.integer :min_days
      t.integer :specific_day
      t.integer :max_days
      t.integer :position
      t.datetime :deleted_at

      t.integer :species_id, foreign_key: true

      t.timestamps null: false
    end
  end
end
