# This migration comes from keppler_reproduction (originally 20190426194530)
class CreateKepplerReproductionCheeseProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_cheese_processes do |t|
      t.date :date
      t.float :received_liters
      t.string :processed_liters
      
      t.integer :farm_id, foreign_key: true, index: true
      t.integer :cheese_type_id, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
