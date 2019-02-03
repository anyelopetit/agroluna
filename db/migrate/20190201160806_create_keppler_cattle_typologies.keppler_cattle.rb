class CreateKepplerCattleTypologies < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_typologies do |t|
      t.string :name
      t.string :abbreviation
      t.string :gender
      t.string :counter
      t.integer :min_age
      t.float :min_weight
      t.text :description
      t.integer :position
      t.datetime :deleted_at

      t.integer :species_id, foreign_key: true

      t.timestamps null: false
    end
  end
end
