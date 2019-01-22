# This migration comes from keppler_cattle (originally 20190121194452)
class AddMoreColumnsToKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_statuses, :days, :integer
    add_column :keppler_cattle_statuses, :farm_id, :integer
    add_column :keppler_cattle_statuses, :gained_weight, :float
    add_column :keppler_cattle_statuses, :breeding, :boolean
  end
end
