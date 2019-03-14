class CreateKepplerCattleCowTypology < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_cow_typologies do |t|

      t.integer :user_id#, foreign_key: true
      t.integer :cow_id, foreign_key: true
      t.integer :typology_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    # add_index :keppler_cattle_cow_typologies, :user_id
    add_index :keppler_cattle_cow_typologies, :cow_id
    add_index :keppler_cattle_cow_typologies, :typology_id
  end
end
