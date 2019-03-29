class CreateKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_statuses do |t|
      t.integer :status_type

      t.date :date
      t.integer :months
      t.boolean :successfully
      t.boolean :twins
      t.text :observations

      t.integer :bull_id, foreign_key: true
      t.integer :user_id, foreign_key: true

      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :keppler_cattle_statuses, :bull_id
    add_index :keppler_cattle_statuses, :user_id
  end
end
