class CreateKepplerFrontendViews < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_frontend_views do |t|
      t.string :name
      t.string :url
      t.boolean :root_path
      t.string :method
      t.boolean :active
      t.string :format_result
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :keppler_frontend_views, :deleted_at
  end
end
