class AddColumnMilkingDateToKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_cows, :milking_date, :date
  end
end
