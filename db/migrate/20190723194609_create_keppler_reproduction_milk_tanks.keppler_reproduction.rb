# This migration comes from keppler_reproduction (originally 20190426194530)
class CreateKepplerReproductionMilkTanks < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_milk_tanks do |t|
      t.string :name
      t.float :milk_capacity
      t.float :milk_contained
      t.text :address
      
      t.integer :farm_id, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
