module KepplerCattle
  # Policy for Species model
  class SpeciesPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end