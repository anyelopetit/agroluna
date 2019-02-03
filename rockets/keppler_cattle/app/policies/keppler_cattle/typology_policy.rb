module KepplerCattle
  # Policy for Typology model
  class TypologyPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end