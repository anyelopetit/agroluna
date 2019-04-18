class CreateKepplerFarmResponsables < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_responsables do |t|
      t.string :name
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
