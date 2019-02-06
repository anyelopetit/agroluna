module KepplerCattle
  # Policy for WeighingDay model
  class WeighingDayPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end