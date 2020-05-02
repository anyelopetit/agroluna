# frozen_string_literal: true

# Class method for start backup.
module Upload
  class Farm
    def self.charge
      # Set initial values.
      @users             = []
      @users_with_errors = []
      @backups           = BulkUpload.find_by(service_name: 'MiRedAbdominalPerimeterService').backups.where(read: false)
      @doctor            = User.find_by(email: 'doctor@mired.com')&.doctor

      # stop proccess if backup or doctor don't exist
      return Rails.logger.info 'Backup or Doctor not found.' if @backups.empty? || @doctor.nil?

      @backups.each do |backup|
        # CSV reading.
        CSV.foreach(backup.file.path, headers: true).each_with_index do |row, index|
          # Convert CSV values to valid values/objects.
          @patient_lab = row.to_h
          parse_object(@patient_lab)
          Rails.logger.info '-------------------------------------------------------------------------'
          Rails.logger.info @patient_lab['Identificacion']
          Rails.logger.info index+1
          Rails.logger.info '-------------------------------------------------------------------------'

          # Find user in db if allready exists, if not use User.new.
          user = find_user(@patient_lab)

          next if user.nil?

          # Validate that current patient hasn't been loaded into db.
          next if user&.patient&.mi_red_abdominal_perimeter_ids&.include?(@patient_lab['custom_id'])

          # Find patient in user
          @patient = user&.patient

          # Validate
          next unless @patient

          # Find MedicalTest or Examen de Laboratorio
          medical_test_type = MedicalTestType.find_by(name: 'Perímetro Abdominal')
          create_medical_test(medical_test_type)

          # Create data from a sample medical type of a medical test
          if @medical_test
            name = 'AbdominalPerimeter'
            specific_test = SpecificTest.find_by(name: name)

            @medical_test.save! if @medical_test.valid?

            test_variable = @medical_test.test_variables.new(
              name: name,
              specific_test: specific_test,
              max_ok: 0,
              min_ok: 0,
              max_regular: 0,
              min_regular: 0
            )

            test_level = @medical_test.test_levels.new(
              value: @patient_lab['CIRCUNFERENCIA ABDOMINAL']&.to_f,
              test_variable: test_variable
            )

            @abdominal_perimeter = AbdominalPerimeter.new(
              first_name:        @patient_lab['Nombre1'],
              second_name:       @patient_lab['Nombre2'],
              surname:           @patient_lab['Ape1'],
              last_name:         @patient_lab['Ape2'],
              eps:               @patient_lab['EPS'],
              dni:               @patient_lab['Identificacion'],
              gender:            @patient_lab['GENERO'],
              date_birthday:     @patient_lab['FECHA DE NACIMIENTO'],
              talla:             @patient_lab['TALLA (m)'],
              peso:              @patient_lab['PESO (kg)'],
              result:            @patient_lab['CIRCUNFERENCIA ABDOMINAL'],
              custom_id:         @patient_lab['custom_id'],
              patient:           @patient,
              medical_test_type: medical_test_type,
              medical_test:      @medical_test
            )

          else
            next
          end

          #Save patient
          if user&.id

            if (@medical_test&.valid?) && (test_variable&.valid?) && (test_level&.valid?) && (@abdominal_perimeter.valid?)
              @medical_test.save!
              test_variable.save!
              test_level.save!
              @abdominal_perimeter.save!
              @patient.abdominal_perimeter = @patient_lab['CIRCUNFERENCIA ABDOMINAL'].to_f
              @patient.mi_red_abdominal_perimeter_ids.push(@patient_lab['custom_id']) unless @patient.mi_red_abdominal_perimeter_ids.include?(@patient_lab['custom_id'])
              @patient.save!
            end

            @users << user
          else
            @users_with_errors << user
          end
        end

        Rails.logger.info 'Finish csv read'
        backup.update(read: true)
        @users
      end
    end

    private

    # Method for convert 'trial' fields in nil.
    def self.parse_object(patient)
      patient.each do |key,value|
        new_value = value&.downcase == '.' ? nil : value
        @patient_lab[key] = new_value
      end

      patient.each do |key,value|
        new_value = value&.downcase&.include?('trial') ? nil : value
        @patient_lab[key] = new_value
      end

      patient.each do |key,value|
        new_value = value&.downcase&.include?('NULL') ? nil : value
        @patient_lab[key] = new_value
      end

      patient.each do |key,value|
        new_value = value&.blank? ? nil : value
        @patient_lab[key] = new_value
      end
    end

    # Method for search existing users in db.
    def self.find_user(patient)
      user = User.find_by(number_id: patient['Identificacion'])
      return user
    end

    def self.create_medical_test(medical_test_type)
      @medical_test = MedicalTest.includes(:test_levels, :test_variables).new(
          order_number:      @patient_lab['custom_id'] + 'MTFIND',
          test_date:         Time.now,
          medical_test_type: medical_test_type,
          doctor:            @doctor,
          patient:           @patient
        )
    end
  end
end
