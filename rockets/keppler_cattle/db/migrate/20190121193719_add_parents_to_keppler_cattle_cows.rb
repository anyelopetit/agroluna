class AddParentsToKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_cows, :mother_id, :integer
    add_column :keppler_cattle_cows, :father_id, :integer
  end
end
