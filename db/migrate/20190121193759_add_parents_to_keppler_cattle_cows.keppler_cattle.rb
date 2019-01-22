# This migration comes from keppler_cattle (originally 20190121193719)
class AddParentsToKepplerCattleCows < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_cows, :mother_id, :integer
    add_column :keppler_cattle_cows, :father_id, :integer
  end
end
