module KepplerCattle
  # Policy for Transference model
  class TransferencePolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end