class CreateKepplerCattleMale < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_males do |t|
      t.boolean :reproductive
      t.boolean :defiant

      t.integer :user_id, foreign_key: true
      t.integer :cow_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_males, :user_id
    add_index :keppler_cattle_males, :cow_id
  end
end
