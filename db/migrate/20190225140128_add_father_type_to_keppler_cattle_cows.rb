class AddFatherTypeToKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_cows, :father_type, :string
  end
end
