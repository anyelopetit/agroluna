class AddFarmIdToKepplerFarmResponsable < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_farm_responsables, :farm_id, :integer
  end
end
