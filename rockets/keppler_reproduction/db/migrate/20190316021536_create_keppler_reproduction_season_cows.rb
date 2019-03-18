class CreateKepplerReproductionSeasonCows < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_season_cows do |t|

      t.integer :season_id, foreign_key: true
      t.integer :cow_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_reproduction_season_cows, :farm_id
    add_index :keppler_reproduction_season_cows, :farm_id
  end
end
