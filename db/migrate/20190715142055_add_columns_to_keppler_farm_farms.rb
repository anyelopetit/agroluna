class AddColumnsToKepplerFarmFarms < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_farm_farms, :milk_lot_id, :integer
    add_column :keppler_farm_farms, :days_to_service, :integer
    add_column :keppler_farm_farms, :days_to_pregnancy, :integer
    add_column :keppler_farm_farms, :days_to_dry, :integer
    add_column :keppler_farm_farms, :days_to_rest, :integer
  end
end
