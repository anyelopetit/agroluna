class AddReproductiveToKepplerCattleTypologies < ActiveRecord::Migration[5.2]
  def change
    add_column :keppler_cattle_typologies, :reproductive, :boolean
  end
end
