# This migration comes from keppler_cattle (originally 20190117122851)
class CreateKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_statuses do |t|
      t.integer :cow_id, foreign_key: true
      t.float :weight
      t.integer :years
      t.integer :months
      t.string :ubication
      t.string :corporal_condition
      t.boolean :reproductive
      t.boolean :defiant
      t.boolean :pregnant
      t.boolean :lactating
      t.boolean :dead
      t.date :deathdate
      t.string :typology
      t.integer :strategic_lot_id
      t.integer :responsable_id
      t.text :comments
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
