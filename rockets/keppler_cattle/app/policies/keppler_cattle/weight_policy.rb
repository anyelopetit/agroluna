module KepplerCattle
  # Policy for Weight model
  class WeightPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end