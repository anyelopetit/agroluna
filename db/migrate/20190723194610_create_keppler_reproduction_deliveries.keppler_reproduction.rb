# This migration comes from keppler_reproduction (originally 20190426194530)
class CreateKepplerReproductionDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_deliveries do |t|
      t.date :date
      t.float :liters
      t.string :destination
      t.string :client_name
      
      t.integer :farm_id, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
