# This migration comes from keppler_cattle (originally 20190613143912)
class KepplerCattleAborts < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_aborts do |t|
      t.date :abort_date
      t.string :reason
      t.string :observations

      t.integer :cow_id, index: true
      t.integer :season_id, index: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
