# This migration comes from keppler_farm (originally 20190108151331)
class CreateKepplerFarmFarms < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_farms do |t|
      t.string :logo
      t.string :title
      t.text :description
      t.jsonb :processes
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
