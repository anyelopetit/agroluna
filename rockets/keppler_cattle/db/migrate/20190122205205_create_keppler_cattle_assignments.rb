class CreateKepplerCattleAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_assignments do |t|
      t.integer :strategic_lot_id, foreign_key: true
      t.integer :cow_id, foreign_key: true

      t.timestamps null: false
    end
    add_index :keppler_cattle_assignments, :strategic_lot_id
    add_index :keppler_cattle_assignments, :cow_id
  end
end
