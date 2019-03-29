# frozen_string_literal: true

# Keppler
module KepplerCattle
  module Concerns
    module CreateCowTypology
      extend ActiveSupport::Concern
      included do
        after_save :create_typology

        def create_typology
          # puts "*** Creando tipología para #{cow.serie_number} ***"
          typology_created = false
          # puts "*** Posibles tipologías para #{cow.serie_number}: ***"
          # puts "*** #{cow.possible_typologies.map {|x| [x.name, x.min_age]}} ***"
          cow.possible_typologies.order(min_age: :asc).each do |typology|
            break if typology_created
            if verify_existence(typology) && verify_counter(typology) && verify_min_age(typology) && verify_min_weight(typology)
              new_typology = cow.cow_typologies.new(
                cow_id: cow.id,
                typology_id: typology.id
              )
              typology_created = new_typology.save ? true : false
              puts "*** Tipología #{typology.name} creada para #{cow.serie_number} (#{cow.short_name}) ***" if typology_created
            end
          end
        end

        private

        def verify_existence(typology)
          cow_typologies = KepplerCattle::CowTypology.where(
            cow_id: cow.id,
            typology_id: typology.id
          )
          cow_typologies.count.zero?
        end

        def verify_counter(typology)
          if typology.counter.to_i == 2
            cow.sons.count > 0
          elsif typology.counter.to_i == 1
            true # TOCHANGE
          else
            true
          end
        end

        def verify_min_age(typology)
          cow.days.to_i > typology.min_age.to_i
        end

        def verify_min_weight(typology)
          cow.weight&.weight.to_f > typology.min_weight.to_f
        end
      end
    end
  end
end