class AddDurationDaysToKepplerReproductionSeasons < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_reproduction_seasons, :duration_days, :integer
    add_column :keppler_reproduction_seasons, :phase, :integer
  end
end
 