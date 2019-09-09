class CreateKepplerCattleMedicalHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_cattle_medical_histories do |t|
      t.date :evaluation_date
      t.references :user, foreign_key: true
      t.text :evualuation
      t.text :diagnostic
      t.date :next_date
      t.integer :position
      t.datetime :deleted_at
    end
  end
end
