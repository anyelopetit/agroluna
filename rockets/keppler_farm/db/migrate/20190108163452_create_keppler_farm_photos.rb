class CreateKepplerFarmPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_farm_photos do |t|
      t.string :photo
      t.boolean :cover
      t.integer :position
      t.integer :farm_id
      t.datetime :deleted_at
    end
  end
end
