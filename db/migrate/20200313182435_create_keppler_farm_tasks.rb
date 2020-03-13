class CreateKepplerFarmTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_tasks do |t|
      t.integer :farm_id
      t.integer :user_id
      t.string :title
      t.text :text
      t.datetime :completed_at

      t.timestamps
    end
  end
end
