# This migration comes from keppler_reproduction (originally 20190426194530)
class CreateKepplerReproductionMilkWeights < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_milk_weights do |t|
      t.date :date
      t.float :morning_liters
      t.float :evening_liters
      t.float :total_liters
      t.text :description
      
      t.integer :farm_id, foreign_key: true, index: true
      t.integer :cow_id, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
