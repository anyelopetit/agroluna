# This file should contain all the record creation needed to seed
# the database with its default values.
# The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)
# user = CreateAdminService.new.call
# puts 'CREATED ADMIN USER: ' << user.email

%i[keppler_admin admin operador veterinario].each do |role|
  Role.create name: 'keppler_admin'
  puts "Role #{role} has been created"
end


User.create!(
  name: 'Keppler Admin', email: 'admin@keppleradmin.com', password: '+12345678+',
  password_confirmation: '+12345678+', role_ids: '1'
)

puts 'admin@keppler.io has been created'


# Create setting deafult
if yml = YAML.load_file("#{Rails.root}/config/settings.yml")
  setting = Setting.create!(
    name: yml['name'],
    description: yml['description'],
    email: yml['email'],
    phone: yml['phone'],
    mobile: yml['mobile'],
    smtp_setting_attributes: {
      address: yml['address'],
      port: yml['port'],
      domain_name: yml['domain_name'],
      email: yml['smtp_email'],
      password: yml['password'] ? yml['password'] : '12345678'
    },
    google_analytics_setting_attributes: {
      ga_account_id: yml['ga_account_id'],
      ga_tracking_id: yml['ga_tracking_id'],
      ga_status: yml['ga_status']
    }
  )
  setting.social_account = SocialAccount.new(
    facebook: yml['facebook'],
    twitter: yml['twitter'],
    instagram: yml['instagram'],
    google_plus: yml['google_plus'],
    tripadvisor: yml['tripadvisor'],
    pinterest: yml['pinterest'],
    flickr: yml['flickr'],
    behance: yml['behance'],
    dribbble: yml['dribbble'],
    tumblr: yml['tumblr'],
    github: yml['github'],
    linkedin: yml['linkedin'],
    soundcloud: yml['soundcloud'],
    youtube: yml['youtube'],
    skype: yml['skype'],
    vimeo: yml['vimeo']
  )
  setting.appearance = Appearance.new(theme_name: yml['theme_name'])
  setting.save!
  puts 'Setting has been created'
else
  setting = Setting.create!(
    name: 'Keppler Admin', description: 'Welcome to Keppler Admin',
    smtp_setting_attributes: {
      address: 'test', port: '25', domain_name: 'keppler.com',
      email: 'info@keppler.com', password: '12345678'
    },
    google_analytics_setting_attributes: {
      ga_account_id: '121648466',
      ga_tracking_id: 'UA-121648466-1',
      ga_status: true
    }
  )
  setting.social_account = SocialAccount.new
  setting.appearance = Appearance.new(theme_name: 'keppler')
  setting.save
  puts 'Setting default has been created'
end

if defined?(KepplerFrontend) && KepplerFrontend.is_a?(Module)
  file =  File.join("#{Rails.root}/rockets/keppler_frontend/config/data/views.yml")
  routes = YAML.load_file(file)
  routes.each do |route|
    KepplerFrontend::View.create!(
      name: route['name'],
      url: route['url'],
      method: route['method'],
      active: route['active'],
      format_result: route['format_result']
    )
  end

  partials_file =  File.join("#{Rails.root}/rockets/keppler_frontend/config/partials.yml")
  partials = YAML.load_file(partials_file)

  partials.each do |partial|
    KepplerFrontend::Partial.create!(
      name: partial['name'],
    )
  end
  puts 'Views and Partials has been created'
end

if defined?(KepplerLanguages) && KepplerLanguages.is_a?(Module)
  languages =  File.join("#{Rails.root}/rockets/keppler_languages/config/languages.yml")
  langs = YAML.load_file(languages)

  langs.each do |lang|
    KepplerLanguages::Language.create!(
      name: lang['name']
    )
  end

  file_fields =  File.join("#{Rails.root}/rockets/keppler_languages/config/fields.yml")
  fields = YAML.load_file(file_fields)

  fields.each do |field|
    KepplerLanguages::Field.create!(
      key: field['key'],
      value: field['value'],
      language_id: field['language_id']
    )
  end
  puts 'Languages has been created'
end

if defined?(KepplerFrontend) && KepplerFrontend.is_a?(Module)
  functions =  File.join("#{Rails.root}/rockets/keppler_frontend/config/functions.yml")
  funcs = YAML.load_file(functions)

  funcs.each do |func|
    KepplerFrontend::Function.create!(
      name: func['name'],
      description: func['description']
    )
  end

  parameters_file =  File.join("#{Rails.root}/rockets/keppler_frontend/config/parameters.yml")
  params = YAML.load_file(parameters_file)

  params.each do |param|
    KepplerFrontend::Parameter.create!(
      name: param['name'],
      function_id: param['function_id']
    )
  end
  puts 'Frontend functions has been created'
end

# App

# Fincas
['Agropecuaria La Luna', 'Finca Agrocabrita'].each do |farm|
  farm = KepplerFarm::Farm.create!(
    title: farm,
    description: Faker::Lorem.paragraph
  )

  # Lotes
  6.times do |i|
    KepplerFarm::StrategicLot.create!(
      name: Faker::Lorem.sentence(3, true, 3),
      function: Faker::Lorem.word,
      description: Faker::Lorem.paragraph,
      farm_id: farm&.id
    )
  end
end
puts 'Fincas y lotes creados'

# Especies
%i[Vacuno].each do |species_name|
  species = KepplerCattle::Species.create!(
    name: species_name,
    abbreviation: species_name.to_s.remove('a', 'e', 'i', 'o', 'u')
  )
  puts "Especie #{species_name} creada"

  # Razas
  30.times do |race_index|
    KepplerCattle::Race.create!(
      name: "Raza #{species_name} #{race_index}",
      abbreviation: "R#{race_index}",
      description: Faker::Lorem.paragraph,
      species_id: species.id
    )
  end
  puts "Razas de specie #{species_name} creadas"

  # Pesajes
  4.times do |weighing|
    KepplerCattle::WeighingDay.create!(
      name: "Pesaje #{species_name} #{weighing}",
      min_days: (210..600).to_a.sample,
      specific_day: (210..600).to_a.sample,
      max_days: (210..600).to_a.sample,
      species_id: species.id
    )
  end
  puts "Pesajes de #{species_name} creadas"

  # Condiciones corporales
  4.times do |corporal_condition|
    KepplerCattle::CorporalCondition.create!(
      name: "Condición Corporal #{species_name} #{corporal_condition}",
      number: corporal_condition,
      description: Faker::Lorem.paragraph,
      species_id: species.id
    )
  end
  puts "Condiciones corporales de #{species_name} creadas"
  
  # Madre Sute
  KepplerCattle::Cow.create!(
    serie_number: '0000',
    short_name: 'Madre Sute',
    gender: 'female',
    species_id: species.id,
    race_id: species.races.sample.id,
    birthdate: Faker::Date.backward(3650),
    coat_color: KepplerCattle::Cow.colors.sample,
    nose_color: KepplerCattle::Cow.colors.sample,
    tassel_color: KepplerCattle::Cow.colors.sample,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph
  )
  puts "Madre sute de #{species.name} creada"
end
puts 'Especies, razas y pesajes creados'


# Tipologías
['BECERRO', 'MAUTE', 'NOVILLO', 'TORO'].each_with_index do |typology, index|
  KepplerCattle::Typology.create!(
    name: "#{typology}",
    abbreviation: typology.remove('a', 'e', 'i', 'o', 'u'),
    gender: 'male',
    min_age: (index * 365),
    min_weight: (index * 50),
    description: Faker::Lorem.paragraph,
    species_id: 1
  )
end

['BECERRA', 'MAUTA', 'NOVILLA', 'VACA'].each_with_index do |typology, index|
  KepplerCattle::Typology.create!(
    name: "#{typology}",
    abbreviation: typology.remove('a', 'e', 'i', 'o', 'u'),
    gender: 'female',
    counter: index.zero? ? 0 : index - 1,
    min_age: (index * 365),
    min_weight: (index * 50),
    description: Faker::Lorem.paragraph,
    species_id: 1
  )
end
puts 'Tipologías creadas'

5.times do |index|
  KepplerFarm::Responsable.create!(
    name: Faker::GameOfThrones.character
  )
end
puts "Responsables creados"

# Series
100.times do |i|
  species = KepplerCattle::Species.all.sample
  cow = KepplerCattle::Cow.create!(
    serie_number: Faker::Number.between(111111, 999999),
    short_name: Faker::Name.first_name,
    # farm_id: [1,2].sample,
    gender: ['male', 'female'].sample,
    species_id: species.id,
    race_id: species.races.sample.id,
    birthdate: Faker::Date.backward(3650),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph,
    mother_id: Faker::Number.between(0000, 999999),
    father_type: KepplerCattle::Cow.to_s,
    father_id: KepplerCattle::Cow.where(gender: 'male')&.sample&.id
  )

  farm = KepplerFarm::Farm.find([1,2].sample)
  KepplerCattle::Location.create!(
    user_id: 1,
    cow_id: cow&.id,
    farm_id: farm&.id,
    strategic_lot_id: farm.strategic_lots.sample.id 
  )
  
  if cow.gender?('male')
    KepplerCattle::Male.create!(
      user_id: User.all.sample.id,
      cow_id: cow&.id,
      reproductive: [true, false].sample,
      defiant: [true, false].sample
    )
  else
    KepplerCattle::Status.create!(
      status_type: 0,
      date: Faker::Date.backward(40),
      months: Faker::Number.between(1, 2),
      user_id: User.all.sample,
      cow_id: cow&.id
    )
  end

  # Pesaje
  5.times do |index|
    actual_weight = Faker::Number.decimal(3)
    responsable = KepplerFarm::Responsable.all.sample
    KepplerCattle::Weight.create!(
      user: responsable,
      cow_id: cow&.id,
      weight: actual_weight.to_f,
      gained_weight: 26.04.nil? ? 0 : (actual_weight.to_f - 24.50),
      average_weight: 26.04.nil? ? 0 : ((actual_weight.to_f - 24.50) / cow.days),
      corporal_condition_id: KepplerCattle::CorporalCondition.all.sample.id,
      observations: Faker::Lorem.paragraph
    )

    KepplerCattle::Activity.create!(
      active: true,
      cow_id: cow&.id,
      observations: Faker::Lorem.paragraph
    )
  end

  # Pajuelas
  KepplerCattle::Insemination.create!(
    serie_number: Faker::Number.between(111111, 999999),
    short_name: Faker::Name.first_name,
    farm_id: [1,2].sample,
    species_id: species&.id,
    race_id: species&.races&.sample&.id,
    mother_id: KepplerCattle::Cow.where(gender: 'female')&.sample&.id,
    # father_type: KepplerCattle::Cow.to_s,
    father_id: KepplerCattle::Cow.where(gender: 'male')&.sample&.id,
    birthdate: Faker::Date.backward(3650),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    quantity: Faker::Number.between(1,10),
    observations: Faker::Lorem.paragraph
  )
end
puts 'Series creadas'

# 2.times do |farm|
#   puts "Llenando #{KepplerFarm::Farm.find(farm+1).title} de 20 transferencias "
#   20.times do |transference|
#     KepplerCattle::Transference.create!(
#       cattle: KepplerFarm::Farm.find_by(id: farm+1).cows.take(transference).pluck(:id),#take([1..20].sample),
#       from_farm_id: farm.eql?(1) ? 1 : 2,
#       to_farm_id: farm.eql?(1) ? 2 : 1,
#       reason: Faker::GameOfThrones.quote
#     )
#   end
# end
# puts 'Transferencias creadas'


species = KepplerCattle::Species.first

8.times do |index|
  cow = KepplerCattle::Cow.create!(
    serie_number: ((index+1)*11111111),
    short_name: "Bisabuelo",#{(index % 2).zero? ? 'o' : 'a'}",
    # farm_id: [1,2].sample,
    gender: ['male', 'female'][index%2],
    species_id: species.id,
    race_id: species.races.sample&.id,
    birthdate: Faker::Date.backward(3650),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph,
    mother_id: KepplerCattle::Cow.where(gender: 'female')&.sample&.id,
    father_type: KepplerCattle::Cow.to_s,
    father_id: KepplerCattle::Cow.where(gender: 'male')&.sample&.id
  )
  actual_weight = Faker::Number.decimal(3)
  KepplerCattle::Weight.create!(
    user_id: 1,
    cow_id: cow&.id,
    weight: actual_weight.to_f,
    gained_weight: 26.04.nil? ? 0 : (actual_weight.to_f - 24.50),
    average_weight: 26.04.nil? ? 0 : ((actual_weight.to_f - 24.50) / cow.days),
    corporal_condition_id: KepplerCattle::CorporalCondition.all.sample.id,
    observations: Faker::Lorem.paragraph
  )

  KepplerCattle::Activity.create!(
    active: true,
    cow_id: cow&.id,
    observations: Faker::Lorem.paragraph
  )

  farm = KepplerFarm::Farm.find([1,2].sample)
  KepplerCattle::Location.create!(
    user_id: 1,
    cow_id: cow&.id,
    farm_id: farm&.id,
    strategic_lot_id: farm.strategic_lots.sample.id 
  )
end
puts 'Bisabuelos creados'

%w[11112222 33334444 55556666 77778888].each_with_index do |serie_number, index|
  cow = KepplerCattle::Cow.create!(
    serie_number: serie_number,
    short_name: "Abuelo",#{index%2.zero? ? 'o' : 'a'}",
    # farm_id: [1,2].sample,
    gender: ['male', 'female'][index%2],
    species_id: species.id,
    race_id: species.races.sample.id,
    birthdate: Faker::Date.backward(3650),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph,
    father_type: KepplerCattle::Cow.to_s,
    father_id: KepplerCattle::Cow.find_by(serie_number: serie_number.first*8).id,
    mother_id: KepplerCattle::Cow.find_by(serie_number: serie_number.last*8).id
  )
  actual_weight = Faker::Number.decimal(2)
  KepplerCattle::Weight.create!(
    user_id: 1,
    cow_id: cow&.id,
    weight: actual_weight.to_f,
    gained_weight: 26.04.nil? ? 0 : (actual_weight.to_f - 24.50),
    average_weight: 26.04.nil? ? 0 : ((actual_weight.to_f - 24.50) / cow.days),
    corporal_condition_id: KepplerCattle::CorporalCondition.all.sample.id,
    observations: Faker::Lorem.paragraph
  )

  KepplerCattle::Activity.create!(
    active: true,
    cow_id: cow&.id,
    observations: Faker::Lorem.paragraph
  )

  farm = KepplerFarm::Farm.find([1,2].sample)
  KepplerCattle::Location.create!(
    user_id: 1,
    cow_id: cow&.id,
    farm_id: farm&.id,
    strategic_lot_id: farm.strategic_lots.sample.id 
  )
end
puts 'Abuelos creados'

%w[11223344 55667788].each_with_index do |serie_number, index|
  cow = KepplerCattle::Cow.create!(
    serie_number: serie_number,
    short_name: "#{['Padre', 'Madre'][index%2]}",
    # farm_id: [1,2].sample,
    gender: ['male', 'female'][index%2],
    species_id: species.id,
    race_id: species.races.sample.id,
    birthdate: Faker::Date.backward(3650),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph,
    father_type: KepplerCattle::Cow.to_s,
    father_id: KepplerCattle::Cow.find_by(serie_number: serie_number[0..1]*2 + serie_number[2..3]*2).id,
    mother_id: KepplerCattle::Cow.find_by(serie_number: serie_number[4..5]*2 + serie_number[6..7]*2).id
  )
  actual_weight = Faker::Number.decimal(2)
  KepplerCattle::Weight.create!(
    user_id: 1,
    cow_id: cow&.id,
    weight: actual_weight.to_f,
    gained_weight: 26.04.nil? ? 0 : (actual_weight.to_f - 24.50),
    average_weight: 26.04.nil? ? 0 : ((actual_weight.to_f - 24.50) / cow.days),
    corporal_condition_id: KepplerCattle::CorporalCondition.all.sample.id,
    observations: Faker::Lorem.paragraph
  )

  KepplerCattle::Activity.create!(
    active: true,
    cow_id: cow&.id,
    observations: Faker::Lorem.paragraph
  )

  farm = KepplerFarm::Farm.find([1,2].sample)
  KepplerCattle::Location.create!(
    user_id: 1,
    cow_id: cow&.id,
    farm_id: farm&.id,
    strategic_lot_id: farm.strategic_lots.sample.id 
  )
end
puts 'Padres creados'


cow = KepplerCattle::Cow.create!(
  serie_number: '12345678',
  short_name: "Hijo",
  # farm_id: [1,2].sample,
  gender: 'male',
  species_id: KepplerCattle::Species.all.sample.id,
  race_id: KepplerCattle::Species.first.races.sample&.id,
  birthdate: Faker::Date.backward(3650),
  coat_color: Faker::Color.color_name,
  nose_color: Faker::Color.color_name,
  tassel_color: Faker::Color.color_name,
  provenance: Faker::LordOfTheRings.location,
  observations: Faker::Lorem.paragraph,
  father_type: KepplerCattle::Cow.to_s,
  father_id: KepplerCattle::Cow.find_by(serie_number: "11223344").id,
  mother_id: KepplerCattle::Cow.find_by(serie_number: "55667788").id
)
actual_weight = Faker::Number.decimal(2)
KepplerCattle::Weight.create!(
  user_id: 1,
  cow_id: cow&.id,
  weight: (50.05 * 1),
  gained_weight: 26.04.nil? ? 0 : ((50.05 * 1) - 24.50),
  average_weight: 26.04.nil? ? 0 : (((50.05 * 1) - 24.50) / cow.days),
  corporal_condition_id: KepplerCattle::CorporalCondition.all.sample.id,
  observations: Faker::Lorem.paragraph
)

KepplerCattle::Activity.create!(
  active: true,
  cow_id: cow&.id,
  observations: Faker::Lorem.paragraph
)

farm = KepplerFarm::Farm.all.sample
KepplerCattle::Location.create!(
  user_id: 1,
  cow_id: cow&.id,
  farm_id: farm&.id,
  strategic_lot_id: farm.strategic_lots.sample.id 
)
puts 'Hijo creado'

puts 'Arbol genealogico creado'