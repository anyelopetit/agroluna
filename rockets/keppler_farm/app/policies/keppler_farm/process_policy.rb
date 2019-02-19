module KepplerFarm
  # Policy for Process model
  class ProcessPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end