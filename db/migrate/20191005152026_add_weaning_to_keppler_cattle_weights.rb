class AddWeaningToKepplerCattleWeights < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_weights, :weaning, :boolean
  end
end
