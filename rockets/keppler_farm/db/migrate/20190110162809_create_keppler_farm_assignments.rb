class CreateKepplerFarmAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_assignments do |t|
      t.references :user, foreign_key: true
      t.references :keppler_farm_farm, foreign_key: true

      t.timestamps
    end
  end
end
