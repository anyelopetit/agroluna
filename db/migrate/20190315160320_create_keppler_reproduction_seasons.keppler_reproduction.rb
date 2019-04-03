# This migration comes from keppler_reproduction (originally 20190315160315)
class CreateKepplerReproductionSeasons < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_seasons do |t|
      t.string :name
      t.string :season_type
      t.date :start_date
      t.date :finish_date

      t.integer :farm_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_reproduction_seasons, :farm_id
  end
end
