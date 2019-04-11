class AddInseminationIdToKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_statuses, :insemination_id, :integer
  end
end
