module KepplerReproduction
  # Policy for Season model
  class SeasonPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end