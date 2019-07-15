class AddMilkingToKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_cows, :milking, :boolean
  end
end
