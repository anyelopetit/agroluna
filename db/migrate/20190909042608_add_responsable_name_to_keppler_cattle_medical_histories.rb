class AddResponsableNameToKepplerCattleMedicalHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_medical_histories, :responsable_name, :string
  end
end
