# frozen_string_literal: true

# Keppler
module KepplerCattle
  module Concerns
    module CreateCowTypology
      extend ActiveSupport::Concern
      included do
        after_save :create_typology

        def create_typology
          puts "*** Creando tipología para #{polymorphic_cow(self).serie_number} ***"
          typology_created = false
          # puts "*** Posibles tipologías para #{polymorphic_cow(self).serie_number}: ***"
          # puts "*** #{polymorphic_cow(self).possible_typologies.map {|x| [x.name, x.min_age]}} ***"
          polymorphic_cow(self).possible_typologies.order(min_age: :asc).each do |typology|
            break if typology_created
            if verify_existence(typology) && verify_counter(typology) && verify_min_age(typology) && verify_min_weight(typology)
              new_typology = polymorphic_cow(self).cow_typologies.new(
                cow_id: polymorphic_cow(self).id,
                typology_id: typology.id
              )
              typology_created = new_typology.save ? true : false
              puts "*** Tipología #{typology&.name} creada para #{polymorphic_cow(self).serie_number} (#{polymorphic_cow(self).short_name}) ***" if typology_created
            end
          end
        end

        private

        def verify_existence(typology)
          cow_typologies = KepplerCattle::CowTypology.where(
            cow_id: polymorphic_cow(self)&.id,
            typology_id: typology&.id
          )
          cow_typologies.size.zero?
        end

        def verify_counter(typology)
          if typology.counter.to_i == 2
            polymorphic_cow(self).sons.exists?
          elsif typology.counter.to_i == 1
            true # TOCHANGE
          else
            true
          end
        end

        def verify_min_age(typology)
          polymorphic_cow(self).days.to_i >= typology.min_age.to_i
        end

        def verify_min_weight(typology)

          polymorphic_cow(self).weight&.weight.to_f >= typology.min_weight.to_f
        end

        protected

        def polymorphic_cow(object_self)
          cow ||=
            if object_self.class.eql?(KepplerCattle::Cow)
              object_self
            else
              object_self.cow
            end
        end
      end
    end
  end
end
