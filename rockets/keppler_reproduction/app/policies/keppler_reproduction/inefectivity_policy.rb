module KepplerReproduction
  # Policy for Inefectivity model
  class InefectivityPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end