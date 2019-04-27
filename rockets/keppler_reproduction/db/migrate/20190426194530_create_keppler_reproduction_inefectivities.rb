class CreateKepplerReproductionInefectivities < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_inefectivities do |t|
      t.integer :season_id
      t.integer :responsable_id
      t.integer :cow_id
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
