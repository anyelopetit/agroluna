module KepplerFarm
  # Policy for Farm model
  class FarmPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
    
    def destroy?
      false
    end
  end
end