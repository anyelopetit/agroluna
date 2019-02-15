# This file should contain all the record creation needed to seed
# the database with its default values.
# The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# user = CreateAdminService.new.call
# puts 'CREATED ADMIN USER: ' << user.email

%i[keppler_admin admin operador veterinario].each do |role|
  Role.create name: 'keppler_admin'
  puts "Role #{role} has been created"
end


User.create(
  name: 'Keppler Admin', email: 'admin@keppleradmin.com', password: '+12345678+',
  password_confirmation: '+12345678+', role_ids: '1'
)

puts 'admin@keppler.io has been created'


# Create setting deafult
if yml = YAML.load_file("#{Rails.root}/config/settings.yml")
  setting = Setting.create(
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
  setting = Setting.create(
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
    KepplerFrontend::View.create(
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
    KepplerFrontend::Partial.create(
      name: partial['name'],
    )
  end
  puts 'Views and Partials has been created'
end

if defined?(KepplerLanguages) && KepplerLanguages.is_a?(Module)
  languages =  File.join("#{Rails.root}/rockets/keppler_languages/config/languages.yml")
  langs = YAML.load_file(languages)

  langs.each do |lang|
    KepplerLanguages::Language.create(
      name: lang['name']
    )
  end

  file_fields =  File.join("#{Rails.root}/rockets/keppler_languages/config/fields.yml")
  fields = YAML.load_file(file_fields)

  fields.each do |field|
    KepplerLanguages::Field.create(
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
    KepplerFrontend::Function.create(
      name: func['name'],
      description: func['description']
    )
  end

  parameters_file =  File.join("#{Rails.root}/rockets/keppler_frontend/config/parameters.yml")
  params = YAML.load_file(parameters_file)

  params.each do |param|
    KepplerFrontend::Parameter.create(
      name: param['name'],
      function_id: param['function_id']
    )
  end
  puts 'Frontend functions has been created'
end

# App

# Fincas
['Agropecuaria La Luna', 'Finca Agrocabrita'].each do |farm|
  farm = KepplerFarm::Farm.create(
    title: farm,
    description: Faker::Lorem.paragraph
  )

  # Lotes
  6.times do |i|
    KepplerFarm::StrategicLot.create(
      name: Faker::Lorem.sentence(3, true, 3),
      function: Faker::Lorem.word,
      description: Faker::Lorem.paragraph,
      farm_id: farm.id
    )
  end
end
puts 'Fincas y lotes creados'

# Especies
%i[Vacuno Caprino Equino].each do |species_name|
  species = KepplerCattle::Species.create(
    name: species_name,
    abbreviation: Faker::Compass.abbreviation
  )

  # Razas
  30.times do |race|
    KepplerCattle::Race.create(
      name: Faker::Pokemon.name,
      abbreviation: Faker::Compass.abbreviation,
      description: Faker::Lorem.paragraph,
      species_id: species.id
    )
  end

  # Tipologías
  ['BECERRO', 'BECERRO SUTE', 'MAUTE', 'NOVILLO', 'TORO', 'TORO PADROTE'].each do |typology|
    KepplerCattle::Typology.create(
      name: typology,
      abbreviation: Faker::Compass.abbreviation,
      gender: 'male',
      counter: ['1', '2'].sample,
      min_age: (0..15).to_a.sample,
      min_weight: (30..600).to_a.sample,
      description: Faker::Lorem.paragraph,
      species_id: species.id
    )
  end

  ['BECERRA', 'BECERRA SUTE', 'MAUTA', 'NOVILLA', 'NOVILLA PREÑADA', 'VACA VACÍA',
    'VACA PROD.VACIA', 'VACA VACÍA SIN CRÍA', 'VACA PREÑADA', 'VACA SECA/HORRA'].each do |typology|
    KepplerCattle::Typology.create(
      name: typology,
      abbreviation: Faker::Compass.abbreviation,
      gender: 'female',
      counter: ['1', '2'].sample,
      min_age: (0..15).to_a.sample,
      min_weight: (30..600).to_a.sample,
      description: Faker::Lorem.paragraph,
      species_id: species.id
    )
  end

  # Pesajes
  4.times do |weighing|
    KepplerCattle::WeighingDay.create(
      name: Faker::Coffee.blend_name,
      min_days: (210..600).to_a.sample,
      specific_day: (210..600).to_a.sample,
      max_days: (210..600).to_a.sample,
      species_id: species.id
    )
  end

  # Madre Sute
  KepplerCattle::Cow.create(
    serie_number: '0000',
    short_name: Faker::Name.first_name,
    gender: ['male', 'female'].sample,
    race_id: species.races.first.id,
    birthdate: Faker::Date.birthday(1, 15),
    coat_color: KepplerCattle::Cow.colors.sample,
    nose_color: KepplerCattle::Cow.colors.sample,
    tassel_color: KepplerCattle::Cow.colors.sample,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph
  )
  puts "Madre sute de #{species.name} creada"
end
puts 'Especies, razas, tipologías y pesajes creadas'

# Series
100.times do |i|
  species = KepplerCattle::Species.find_by(id: [1,2,3].sample)
  cow = KepplerCattle::Cow.create(
    serie_number: Faker::Number.between(111111, 999999),
    short_name: Faker::Name.first_name,
    # farm_id: [1,2].sample,
    gender: ['male', 'female'].sample,
    species_id: species.id,
    race_id: species.races.first.id,
    birthdate: Faker::Date.birthday(1, 15),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph,
    mother_id: Faker::Number.between(0000, 999999),
    father_id: Faker::Number.between(1111, 9999)
  )

  # Estatus
  10.times do |status|
    KepplerCattle::Status.create(
      cow_id: cow.id,
      weight: Faker::Number.decimal(2),
      years: cow.years,
      months: cow.months,
      days: cow.days,
      dead: [true, false].sample,
      corporal_condition: "CONDICION CORPORAL #{(0..5).to_a.sample}",
      typology_id: KepplerCattle::Typology.find_by(id: (1..10).to_a.sample).id,
      strategic_lot_id: (1..5).to_a.sample,
      user_id: 1,
      comments: Faker::Lorem.paragraph,
      farm_id: [1,2].sample
    )
  end

  # Asignación a lote
  KepplerCattle::Assignment.create(
    strategic_lot_id: (1..12).to_a.sample,
    cow_id: cow.id
  )

  # Pajuelas
  KepplerCattle::Insemination.create(
    serie_number: Faker::Number.between(111111, 999999),
    short_name: Faker::Name.first_name,
    farm_id: [1,2].sample,
    species_id: species&.id,
    race_id: species&.races&.sample&.id,
    mother_id: KepplerCattle::Cow.where(gender: 'female')&.sample&.id,
    father_id: KepplerCattle::Cow.where(gender: 'male')&.sample&.id,
    birthdate: Faker::Date.birthday(1, 15),
    coat_color: Faker::Color.color_name,
    nose_color: Faker::Color.color_name,
    tassel_color: Faker::Color.color_name,
    provenance: Faker::LordOfTheRings.location,
    observations: Faker::Lorem.paragraph
  )
end
puts 'Series creadas'

2.times do |farm|
  puts "Llenando #{KepplerFarm::Farm.find(farm+1).title} de 20 transferencias "
  20.times do |transference|
    KepplerCattle::Transference.create(
      cattle: KepplerFarm::Farm.find_by(id: farm+1).cows.take(transference).pluck(:id),#take([1..20].sample),
      from_farm_id: farm.eql?(1) ? 1 : 2,
      to_farm_id: farm.eql?(1) ? 2 : 1,
      reason: Faker::GameOfThrones.quote
    )
  end
end
puts 'Transferencias creadas'

