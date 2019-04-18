class AddFinishedToKepplerReproductionSeason < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_reproduction_seasons, :finished, :boolean
  end
end
