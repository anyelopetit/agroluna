class AddWeightingDateToKepplerCattleWeights < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_weights, :weighting_date, :date
  end
end
