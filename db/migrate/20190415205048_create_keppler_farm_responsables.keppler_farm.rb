# This migration comes from keppler_farm (originally 20190415205041)
class CreateKepplerFarmResponsables < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_responsables do |t|
      t.string :name
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
