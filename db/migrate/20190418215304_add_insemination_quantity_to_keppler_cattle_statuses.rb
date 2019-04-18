class AddInseminationQuantityToKepplerCattleStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_statuses, :insemination_quantity, :integer
  end
end
