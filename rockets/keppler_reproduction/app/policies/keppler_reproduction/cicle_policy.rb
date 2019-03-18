module KepplerReproduction
  # Policy for Cicle model
  class CiclePolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end