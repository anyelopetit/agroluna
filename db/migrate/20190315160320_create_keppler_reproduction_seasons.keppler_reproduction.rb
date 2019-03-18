# This migration comes from keppler_reproduction (originally 20190315160315)
class CreateKepplerReproductionSeasons < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_seasons do |t|
      t.string :name
      t.date :start_date
      t.integer :farm_id
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
