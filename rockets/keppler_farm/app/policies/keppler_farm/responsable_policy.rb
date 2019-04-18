module KepplerFarm
  # Policy for Responsable model
  class ResponsablePolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end