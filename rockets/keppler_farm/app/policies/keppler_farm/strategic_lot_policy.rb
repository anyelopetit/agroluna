module KepplerFarm
  # Policy for StrategicLot model
  class StrategicLotPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end