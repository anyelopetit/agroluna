class CreateKepplerCattleAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_assignments do |t|
      t.references :strategic_lot, foreign_key: true
      t.references :cow, foreign_key: true

      t.timestamps
    end
  end
end
