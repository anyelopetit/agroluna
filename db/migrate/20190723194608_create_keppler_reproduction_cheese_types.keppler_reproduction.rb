# This migration comes from keppler_reproduction (originally 20190426194530)
class CreateKepplerReproductionCheeseTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_reproduction_cheese_types do |t|
      t.string :name
      t.float :liters_needed

      t.timestamps null: false
    end
  end
end
