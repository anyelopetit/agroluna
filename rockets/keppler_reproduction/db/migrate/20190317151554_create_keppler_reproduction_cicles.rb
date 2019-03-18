class CreateKepplerReproductionCicles < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_cicles do |t|
      t.string :name
      t.integer :days_count
      t.date :start_date
      t.date :end_date

      t.integer :season_id, foreign_key: true
      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_reproduction_cicles, :season_id
  end
end
