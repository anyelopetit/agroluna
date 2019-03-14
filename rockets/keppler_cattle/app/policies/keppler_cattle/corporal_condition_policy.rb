module KepplerCattle
  # Policy for CorporalCondition model
  class CorporalConditionPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end