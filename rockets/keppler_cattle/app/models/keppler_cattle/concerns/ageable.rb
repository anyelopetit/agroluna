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
            now.year - age.year - (age.to_date.change(:year => now.year) <= now.year ? 0 : 1) :
            0
        end 

        def months
          age = birthdate&.nil? ? created_at : birthdate
          now = Time.now.utc.to_date 
          now.month >= age.month ? (now.month - age.month) : (12 - (age.month - now.month))
        end

        def days
          age = birthdate&.nil? ? created_at : birthdate
          now = Time.now.utc.to_date 
          days_count = 0
          # Suma de los años completos que han pasado x 365
          for y in age.year+1..now.year-1
            for m in 01..12
              days_count += Time.days_in_month(m, y)
            end
          end
          # Suma desde el mes que naciste hasta finalizar ese año
          if now.year > age.year
            for m in age.month..12
              days_count += Time.days_in_month(m, age.year)
            end
            # Suma desde el primero de enero hasta un mes antes de ahora
            for m in 1..now.month-1
              days_count += Time.days_in_month(m, now.year)
            end
          end
          # Suma o resta de los días del mes actual con tu día de nacimiento
          if age.month < now.month
            days_count += Time.days_in_month(age.month, now.year) - age.day
            days_count += now.day
          elsif age.month == now.month
            if age.day > now.day
              days_count -= (age.day - now.day)
            else
              days_count += (now.day - age.day)
            end
          elsif age.month > now.month
            days_count -= Time.days_in_month(now.month, now.year) - now.day
            days_count -= age.day
          end
          days_count
        end
      end
    end
  end
end