class AddFieldsToKepplerReproductionCheeseProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_reproduction_cheese_processes, :real_cheese, :float
    add_column :keppler_reproduction_cheese_processes, :responsable_id, :integer
  end
end
