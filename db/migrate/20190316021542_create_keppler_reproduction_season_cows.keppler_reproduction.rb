# This migration comes from keppler_reproduction (originally 20190316021536)
class CreateKepplerReproductionSeasonCows < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_season_cows do |t|
      t.integer :season_id
      t.integer :cow_id
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
