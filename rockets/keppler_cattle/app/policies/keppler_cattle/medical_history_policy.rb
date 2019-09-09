module KepplerCattle
  # Policy for MedicalHistory model
  class MedicalHistoryPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end
  end
end