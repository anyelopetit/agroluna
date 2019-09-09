class AddCowIdToKepplerCattleMedicalHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_medical_histories, :cow_id, :integer
  end
end
