# This migration comes from keppler_farm (originally 20200419173955)
class CreateKepplerFarmGrounds < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_grounds do |t|
      t.string :identifier
      t.string :name
      t.string :location
      t.float :total_area
      t.float :used_area
      t.string :cultivation
      t.float :efficiency
      t.float :forage_offer
      t.text :description
      t.integer :rest_days
      t.integer :busy_days
      t.float :fecal_effectiveness
      t.integer :farm_id
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
