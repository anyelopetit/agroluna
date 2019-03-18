module KepplerReproduction
  # Policy for SeasonCow model
  class SeasonCowPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end