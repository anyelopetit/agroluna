class AddMilkingToKepplerCattleTypologies < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_typologies, :milking, :boolean
  end
end
