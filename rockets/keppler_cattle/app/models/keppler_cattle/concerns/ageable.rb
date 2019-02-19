# frozen_string_literal: true

# Keppler
module KepplerCattle
  module Concerns
    module Ageable
      extend ActiveSupport::Concern
      included do
        def years 
          now = Time.now.utc.to_date 
          now.year > birthdate.year ?
            now.year - birthdate.year - (birthdate.to_date.change(:year => now.year) <= now.year ? 0 : 1) :
            0
        end 

        def months
          now = Time.now.utc.to_date 
          now.month >= birthdate.month ? (now.month - birthdate.month) : (12 - (birthdate.month - now.month))
        end

        def days
          now = Time.now.utc.to_date 
          days_count = 0
          # Suma de los años completos que han pasado x 365
          for y in birthdate.year+1..now.year-1
            for m in 01..12
              days_count += Time.days_in_month(m, y)
            end
          end
          # Suma desde el mes que naciste hasta finalizar ese año
          if now.year > birthdate.year
            for m in birthdate.month..12
              days_count += Time.days_in_month(m, birthdate.year)
            end
            # Suma desde el primero de enero hasta un mes antes de ahora
            for m in 1..now.month-1
              days_count += Time.days_in_month(m, now.year)
            end
          end
          # Suma o resta de los días del mes actual con tu día de nacimiento
          if birthdate.day > now.day
            days_count -= (birthdate.day - now.day)
          else
            days_count += (now.day - birthdate.day)
          end
        end

        def next_day
          days_list = [210, 365, 540, 730]
          left = 999
          next_d = 0
          days_list.each do |d|
            if (d - days < left && d - days > 0)
              left = (days - d) 
              next_d = d
            end
          end
          next_d
        end
      end
    end
  end
end