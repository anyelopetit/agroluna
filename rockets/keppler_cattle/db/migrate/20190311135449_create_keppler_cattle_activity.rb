class CreateKepplerCattleActivity < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_activities do |t|
      t.boolean :active
      t.text :observations

      t.integer :user_id#, foreign_key: true
      t.integer :cow_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    # add_index :keppler_cattle_activities, :user_id
    add_index :keppler_cattle_activities, :cow_id
  end
end
