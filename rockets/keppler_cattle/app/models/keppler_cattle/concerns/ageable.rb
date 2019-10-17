# frozen_string_literal: true

# Keppler
module KepplerCattle
  module Concerns
    module Ageable
      extend ActiveSupport::Concern
      included do
        def years
          age = birthdate&.nil? ? created_at : birthdate
          now = Time.now.utc.to_date 
          now.year > age.year ?
            now.year - age.year - (age.month <= now.month ? 0 : 1) :
            0
        end 

        def months
          age = birthdate&.nil? ? created_at : birthdate
          now = Time.now.utc.to_date 
          now.month >= age.month ? (now.month - age.month) : (12 - (age.month - now.month))
        end

        def days
          age = birthdate&.nil? ? created_at : birthdate
          now = Date.current
          (now - age).to_i
        end
      end
    end
  end
end