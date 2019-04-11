class AddTypeToKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    change_column :keppler_cattle_statuses, :status_type, :string
  end
end
