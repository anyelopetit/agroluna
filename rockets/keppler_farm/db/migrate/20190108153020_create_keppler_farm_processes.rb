class CreateKepplerFarmProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_processes do |t|
      t.string :title
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
