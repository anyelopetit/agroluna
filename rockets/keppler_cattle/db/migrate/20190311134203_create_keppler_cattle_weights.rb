class CreateKepplerCattleWeights < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_weights do |t|
      t.float :weight
      t.float :gained_weight
      t.float :average_weight
      t.date :weight_date
      t.text :observations

      t.integer :user_id, foreign_key: true
      t.integer :cow_id, foreign_key: true
      t.integer :corporal_condition_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_weights, :user_id
    add_index :keppler_cattle_weights, :cow_id
    add_index :keppler_cattle_weights, :corporal_condition_id
  end
end
