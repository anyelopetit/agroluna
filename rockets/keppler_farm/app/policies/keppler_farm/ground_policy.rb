module KepplerFarm
  # Policy for Ground model
  class GroundPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end