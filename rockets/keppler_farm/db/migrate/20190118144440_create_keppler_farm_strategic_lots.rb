class CreateKepplerFarmStrategicLots < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_strategic_lots do |t|
      t.string :name
      t.string :function
      t.text :description
      t.integer :farm_id
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
