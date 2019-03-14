class CreateKepplerCattlePregnancy < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_pregnancies do |t|
      t.date :pregnancy_date
      t.integer :pregancy_months
      t.text :observations

      t.string :reproductor_type
      t.integer :reproductor_id, foreign_key: true

      t.integer :user_id, foreign_key: true
      t.integer :cow_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_pregnancies, :user_id
    add_index :keppler_cattle_pregnancies, :cow_id
    add_index :keppler_cattle_pregnancies, :reproductor_id
  end
end
