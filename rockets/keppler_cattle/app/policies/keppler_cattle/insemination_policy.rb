module KepplerCattle
  # Policy for Insemination model
  class InseminationPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end