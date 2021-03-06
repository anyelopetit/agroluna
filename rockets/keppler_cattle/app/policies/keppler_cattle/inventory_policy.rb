module KepplerCattle
  # Policy for Inventory model
  class InventoryPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end