# This migration comes from keppler_cattle (originally 20190122205205)
class CreateKepplerCattleAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_assignments do |t|
      t.integer :strategic_lot_id, foreign_key: true
      t.integer :cow_id, foreign_key: true

      t.timestamps
    end
  end
end
