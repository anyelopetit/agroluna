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
# puts "\n# ===> CREATED ADMIN USER: ' << user.emai\n\n\n"

%i[keppler_admin admin operador veterinario].each do |role|
  Role.create name: 'keppler_admin'
  puts "\n# ===> Role #{role} has been created\n\n\n"
end


User.create!(
  name: 'Keppler Admin', email: 'admin@keppleradmin.com', password: '+12345678+',
  password_confirmation: '+12345678+', role_ids: '1'
)

puts "\n# ===> admin@keppler.io has been created\n\n\n"


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
  puts "\n# ===> Setting has been created\n\n\n"
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
  puts "\n# ===> Setting default has been created\n\n\n"
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
  puts "\n# ===> Views and Partials has been created\n\n\n"
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
  puts "\n# ===> Languages has been created\n\n\n"
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
  puts "\n# ===> Frontend functions has been created\n\n\n"
end

### App

COWS =
  CSV
    .read('originaldb/SGANIM.csv') # Cows Table
    .reject { |row| row[75].eql?('True') } # Reject EsPajuelaPadre == 'True'
    .sort_by { |row| row[7].blank? ? row[0] : row[7] } # Sort by FNAC
INSEMINATIONS =
  CSV
    .read('originaldb/SGANIM.csv') # Cows Table
    .select { |row| row[75].eql?('True') } # Select EsPajuelaPadre == 'True'
    .sort_by { |row| row[7].blank? ? row[0] : row[7] } # Sort by FNAC

# Fincas
['Agropecuaria La Luna'].each do |farm_name|
  farm = KepplerFarm::Farm.create(
    title: farm_name,
    description: farm_name
  )

  # Lotes
  # 6.times do |i|
  #   KepplerFarm::StrategicLot.create(
  #     name: Faker::Lorem.sentence(3, true, 3),
  #     function: Faker::Lorem.word,
  #     description: Faker::Lorem.paragraph,
  #     farm_id: farm&.id
  #   )
  # end
  # puts "\n# ===> Fincas y lotes creados\n\n\n"
end

# Especies
%i[Vacuno].each do |species_name|
  species = KepplerCattle::Species.create!(
    name: species_name,
    abbreviation: species_name.to_s.remove('a', 'e', 'i', 'o', 'u')
  )
  puts "\n# ===> Especie #{species_name} creada\n\n\n"

  # Razas
  COWS
    .sort_by { |row| row[11].blank? ? row[0] : row[11] } # Sort by RAZA
    .each_with_index do |row, index|
    next if index.zero? || row[11].blank?
    next if KepplerCattle::Race.find_by(name: row[11])
    race = KepplerCattle::Race.find_or_create_by!(
      name: row[11],
      abbreviation: row[11].remove('a', 'e', 'i', 'o', 'u').first(6),
      description: "Raza #{row[11]}",
      species_id: 1
    )
    puts race.inspect
  end
  puts "\n# ===> Razas de specie #{species_name} creadas\n\n\n"

  # Pesajes
  4.times do |index|
    weighing = KepplerCattle::WeighingDay.create!(
      name: "Pesaje #{species_name} #{index}",
      min_days: (180..200).to_a.sample,
      specific_day: (200..210).to_a.sample,
      max_days: (210..230).to_a.sample,
      species_id: species.id
    )
    puts weighing.inspect
  end
  puts "\n# ===> Pesajes de #{species_name} creadas\n\n\n"

  # Condiciones corporales
  COWS
    .sort_by { |row| row[18].blank? ? row[0] : row[18] }.uniq # sort by ESTADO
    .each_with_index do |row, index|
    next if index.zero? || row[18].blank?
    next if KepplerCattle::CorporalCondition.find_by(name: row[18])
    condition = KepplerCattle::CorporalCondition.find_or_create_by!(
      name: row[18],
      number: row[18].to_i,
      description: "Condición Corporal #{row[18].to_i} de especie #{species_name}",
      species_id: 1
    )
    puts condition.inspect
  end
  puts "\n# ===> Condiciones corporales de #{species_name} creadas\n\n\n"

  # Madre Sute
  sute = KepplerCattle::Cow.create!(
    serie_number: '0000',
    short_name: 'Madre Sute',
    gender: 'female',
    species_id: species.id,
    race_id: species.races.sample&.id,
    birthdate: Date.new(2000, 01, 01),
    provenance: 'Sin procedencia',
    observations: 'Madre de los becerros huérfanos o Sute'
  )
  puts sute.inspect
  puts "\n# ===> Madre sute de #{species.name} creada\n\n\n"
end
puts "\n# ===> Especies, razas y pesajes creados\n\n\n"


# Tipologías
['BECERRO', 'MAUTE', 'NOVILLO', 'TORO'].each_with_index do |typology, index|
  typo = KepplerCattle::Typology.create!(
    name: "#{typology}",
    abbreviation: typology.remove('a', 'e', 'i', 'o', 'u'),
    gender: 'male',
    min_age: (index * 365),
    min_weight: (index * 50),
    description: Faker::Lorem.paragraph,
    species_id: 1
  )
  puts typo.inspect
end

['BECERRA', 'MAUTA', 'NOVILLA', 'VACA'].each_with_index do |typology, index|
  typo = KepplerCattle::Typology.create!(
    name: "#{typology}",
    abbreviation: typology.remove('a', 'e', 'i', 'o', 'u'),
    gender: 'female',
    counter: index.zero? ? 0 : index - 1,
    min_age: (index * 365),
    min_weight: (index * 50),
    description: Faker::Lorem.paragraph,
    species_id: 1
  )
  puts typo.inspect
end
puts "\n# ===> Tipologías creadas\n\n\n"

5.times do |index|
  res = KepplerFarm::Responsable.create!(
    name: "Persona Responsable #{index}"
  )
  puts res.inspect
end
puts "\n# ===> Responsables creados\n\n\n"

# Series
# ["SERIE (0)", "NOMBRE (1)", "CODM (2)", "NOMBREM (3)", "CODP (4)", "NOMBREP (5)", "PAJU (6)", "FNAC (7)", 
# "FECR (8)", "FECS (9)", "TIPO (10)", "RAZA (11)", "SEXO (12)", "COLORBO (13)", "COLORPE (14)", "COLORMO (15)", 
# "OBSER (16)", "PROCEDE (17)", "ESTADO (18)", "PESOI (19)", "PRECIO (20)", "PPIES (21)", "PESACT (22)", "FULPES (23)", 
# "PESDES (24)", "FECDES (25)", "NPARTO (26)", "DPARTO (27)", "NSERVI (28)", "FECUA (29)", "FECUP (30)", "ABORTO (31)", 
# "EDADPP (32)", "PESOPP (33)", "TIPOAP (34)", "TIPOPS (35)", "LOTE (36)", "LPROD (37)", "LPAST (38)", "LNACI (39)", 
# "LTEMP (40)", "ASOC1 (41)", "SERIE1 (42)", "ASOC2 (43)", "SERIE2 (44)", "ASOC3 (45)", "SERIE3 (46)", "ULTGDP (47)", 
# "COD (48)", "CODAP (49)", "CODPS (50)", "TIPOREGISTRO1 (51)", "TIPOREGISTRO2 (52)", "RAZAPADRE (53)", "RAZAMADRE (54)", 
# "FECNACPADRE (55)", "FECNACMADRE (56)", "NROREGPADRE1 (57)", "NROREGPADRE2 (58)", "NROREGMADRE1 (59)", "NROREGMADRE2 (60)", 
# "ASOCPADRE1 (61)", "ASOCPADRE2 (62)", "ASOCMADRE1 (63)", "ASOCMADRE2 (64)", "TIPOREGPADRE1 (65)", "TIPOREGPADRE2 (66)", 
# "TIPOREGMADRE1 (67)", "TIPOREGMADRE2 (68)", "CODAINIORD (69)", "Pa1 (70)", "Pa2 (71)", "Pa3 (72)", "Pa4 (73)", "UA (74)", 
# "EsPajuelaPadre (75)", "Vaquera (76)", "Historia (77)", "NCRIAS (78)", "NPARREPOR (79)", "NABOREPOR (80)"]
COWS.each_with_index do |row, i|
  next if i.zero?
  species = KepplerCattle::Species.first
  date = row[7]
  puts "===> DATE ANTES = #{date}"
  date = (row[7].blank? ? Date.current : row[7].to_date rescue Date.current)
  puts "===> DATE DESPUES = #{date}"
  cow = KepplerCattle::Cow.create!(
    serie_number: row[0],
    short_name: row[1],
    # farm_id: [1,2].sample,
    gender: row[12].eql?('True') ? 'male' : 'female',
    species_id: species.id,
    race_id: KepplerCattle::Race.find_by(name: row[11])&.id || 1, # <========
    birthdate: date,
    coat_color: row[14],
    nose_color: row[15],
    tassel_color: row[13],
    provenance: row[17],
    observations: row[16],
    mother_id: KepplerCattle::Cow.find_by(serie_number: row[2])&.id || 1, # <========
    father_type: KepplerCattle::Cow.to_s,
    father_id: KepplerCattle::Cow.find_by(serie_number: row[4])&.id
  )
  puts cow.inspect

  farm = KepplerFarm::Farm.find([1].sample)
  location = KepplerCattle::Location.create!(
    user_id: 1,
    cow_id: cow&.id,
    farm_id: farm&.id,
    # strategic_lot_id: farm.strategic_lots.sample&.id
  )
  puts location.inspect

  if cow.gender?('male')
    male = KepplerCattle::Male.create!(
      user_id: User.all.sample&.id,
      cow_id: cow&.id,
      reproductive: [true, false].sample,
      defiant: [true, false].sample
    )
    puts male.inspect
  else
    status = KepplerCattle::Status.create!(
      status_type: 0,
      date: Faker::Date.backward(40),
      months: Faker::Number.between(1, 2),
      user_id: User.all.sample,
      cow_id: cow&.id
    )
    puts status.inspect
  end

  # Pesaje
  actual_weight = Faker::Number.decimal(3)
  responsable = KepplerFarm::Responsable.all.sample
  weight = KepplerCattle::Weight.create!(
    user_id: responsable.id,
    cow_id: cow&.id,
    weight: actual_weight.to_f,
    gained_weight: 0,
    average_weight: row[19].to_f / cow.days,
    corporal_condition_id: KepplerCattle::CorporalCondition.find_by(name: row[18])&.id || 1, # <========
    observations: "Peso Inicial fue de #{row[19]}"
  )
  puts weight.inspect

  act = KepplerCattle::Activity.create!(
    active: true,
    cow_id: cow&.id,
    observations: "Animal recién creado"
  )
  puts act.inspect
end
puts "\n# ===> Series creadas\n\n\n"

# Pajuelas
INSEMINATIONS.each_with_index do |row, index|
  next if index.zero?
  species = KepplerCattle::Species.first
  inse = KepplerCattle::Insemination.create!(
    serie_number: row[0],
    short_name: row[1],
    farm_id: [1].sample,
    species_id: species.id,
    race_id: KepplerCattle::Race.find_by(name: row[11])&.id || 1, # <========
    birthdate: (row[7].blank? ? Date.current : row[7].to_date rescue Date.current),
    coat_color: row[14],
    nose_color: row[15],
    tassel_color: row[13],
    provenance: row[17],
    quantity: Faker::Number.between(1,10),
    observations: row[16],
    mother_id: KepplerCattle::Cow.find_by(serie_number: row[2])&.id || 1, # <========
    father_id: KepplerCattle::Cow.find_by(serie_number: row[4])&.id
  )
  puts inse.inspect
end

# 2.times do |farm|
#   puts "\n# ===> Llenando #{KepplerFarm::Farm.find(farm+1).title} de 20 transferencias \n\n\n"
#   20.times do |transference|
#     KepplerCattle::Transference.create!(
#       cattle: KepplerFarm::Farm.find_by(id: farm+1).cows.take(transference).pluck(:id),#take([1..20].sample),
#       from_farm_id: farm.eql?(1) ? 1 : 2,
#       to_farm_id: farm.eql?(1) ? 2 : 1,
#       reason: Faker::GameOfThrones.quote
#     )
#   end
# end
# puts "\n# ===> Transferencias creadas\n\n\n"


# species = KepplerCattle::Species.first

# 8.times do |index|
#   cow = KepplerCattle::Cow.create!(
#     serie_number: ((index+1)*11111111),
#     short_name: "Bisabuelo",#{(index % 2).zero? ? 'o' : 'a'}",
#     # farm_id: [1,2].sample,
#     gender: ['male', 'female'][index%2],
#     species_id: species.id,
#     race_id: species.races.sample&.id,
#     birthdate: Faker::Date.backward(3650),
#     coat_color: Faker::Color.color_name,
#     nose_color: Faker::Color.color_name,
#     tassel_color: Faker::Color.color_name,
#     provenance: Faker::LordOfTheRings.location,
#     observations: Faker::Lorem.paragraph,
#     mother_id: KepplerCattle::Cow.where(gender: 'female')&.sample&.id,
#     father_type: KepplerCattle::Cow.to_s,
#     father_id: KepplerCattle::Cow.where(gender: 'male')&.sample&.id
#   )
#   actual_weight = Faker::Number.decimal(3)
#   KepplerCattle::Weight.create!(
#     user_id: 1,
#     cow_id: cow&.id,
#     weight: actual_weight.to_f,
#     gained_weight: row[19],
#     average_weight: row[19].to_f / cow.days,
#     corporal_condition_id: KepplerCattle::CorporalCondition.find_by(name: row[18]),
#     observations: Faker::Lorem.paragraph
#   )

#   KepplerCattle::Activity.create!(
#     active: true,
#     cow_id: cow&.id,
#     observations: Faker::Lorem.paragraph
#   )

#   farm = KepplerFarm::Farm.find([1].sample)
#   KepplerCattle::Location.create!(
#     user_id: 1,
#     cow_id: cow&.id,
#     farm_id: farm&.id,
#     # strategic_lot_id: farm.strategic_lots.sample&.id
#   )
# end
# puts "\n# ===> Bisabuelos creados\n\n\n"

# %w[11112222 33334444 55556666 77778888].each_with_index do |serie_number, index|
#   cow = KepplerCattle::Cow.create!(
#     serie_number: serie_number,
#     short_name: "Abuelo",#{index%2.zero? ? 'o' : 'a'}",
#     # farm_id: [1,2].sample,
#     gender: ['male', 'female'][index%2],
#     species_id: species.id,
#     race_id: species.races.sample&.id,
#     birthdate: Faker::Date.backward(3650),
#     coat_color: Faker::Color.color_name,
#     nose_color: Faker::Color.color_name,
#     tassel_color: Faker::Color.color_name,
#     provenance: Faker::LordOfTheRings.location,
#     observations: Faker::Lorem.paragraph,
#     father_type: KepplerCattle::Cow.to_s,
#     father_id: KepplerCattle::Cow.find_by(serie_number: serie_number.first*8)&.id,
#     mother_id: KepplerCattle::Cow.find_by(serie_number: serie_number.last*8)&.id
#   )
#   actual_weight = Faker::Number.decimal(2)
#   KepplerCattle::Weight.create!(
#     user_id: 1,
#     cow_id: cow&.id,
#     weight: actual_weight.to_f,
#     gained_weight: row[19],
#     average_weight: row[19].to_f / cow.days,
#     corporal_condition_id: KepplerCattle::CorporalCondition.find_by(name: row[18]),
#     observations: Faker::Lorem.paragraph
#   )

#   KepplerCattle::Activity.create!(
#     active: true,
#     cow_id: cow&.id,
#     observations: Faker::Lorem.paragraph
#   )

#   farm = KepplerFarm::Farm.find([1].sample)
#   KepplerCattle::Location.create!(
#     user_id: 1,
#     cow_id: cow&.id,
#     farm_id: farm&.id,
#     # strategic_lot_id: farm.strategic_lots.sample&.id
#   )
# end
# puts "\n# ===> Abuelos creados\n\n\n"

# %w[11223344 55667788].each_with_index do |serie_number, index|
#   cow = KepplerCattle::Cow.create!(
#     serie_number: serie_number,
#     short_name: "#{['Padre', 'Madre'][index%2]}",
#     # farm_id: [1,2].sample,
#     gender: ['male', 'female'][index%2],
#     species_id: species.id,
#     race_id: species.races.sample&.id,
#     birthdate: Faker::Date.backward(3650),
#     coat_color: Faker::Color.color_name,
#     nose_color: Faker::Color.color_name,
#     tassel_color: Faker::Color.color_name,
#     provenance: Faker::LordOfTheRings.location,
#     observations: Faker::Lorem.paragraph,
#     father_type: KepplerCattle::Cow.to_s,
#     father_id: KepplerCattle::Cow.find_by(serie_number: serie_number[0..1]*2 + serie_number[2..3]*2)&.id,
#     mother_id: KepplerCattle::Cow.find_by(serie_number: serie_number[4..5]*2 + serie_number[6..7]*2)&.id
#   )
#   actual_weight = Faker::Number.decimal(2)
#   KepplerCattle::Weight.create!(
#     user_id: 1,
#     cow_id: cow&.id,
#     weight: actual_weight.to_f,
#     gained_weight: row[19],
#     average_weight: row[19].to_f / cow.days,
#     corporal_condition_id: KepplerCattle::CorporalCondition.find_by(name: row[18]),
#     observations: Faker::Lorem.paragraph
#   )

#   KepplerCattle::Activity.create!(
#     active: true,
#     cow_id: cow&.id,
#     observations: Faker::Lorem.paragraph
#   )

#   farm = KepplerFarm::Farm.find([1].sample)
#   KepplerCattle::Location.create!(
#     user_id: 1,
#     cow_id: cow&.id,
#     farm_id: farm&.id,
#     # strategic_lot_id: farm.strategic_lots.sample&.id
#   )
# end
# puts "\n# ===> Padres creados\n\n\n"


# cow = KepplerCattle::Cow.create!(
#   serie_number: '12345678',
#   short_name: "Hijo",
#   # farm_id: [1,2].sample,
#   gender: 'male',
#   species_id: KepplerCattle::Species.all.sample&.id,
#   race_id: KepplerCattle::Species.first.races.sample&.id,
#   birthdate: Faker::Date.backward(3650),
#   coat_color: Faker::Color.color_name,
#   nose_color: Faker::Color.color_name,
#   tassel_color: Faker::Color.color_name,
#   provenance: Faker::LordOfTheRings.location,
#   observations: Faker::Lorem.paragraph,
#   father_type: KepplerCattle::Cow.to_s,
#   father_id: KepplerCattle::Cow.find_by(serie_number: "11223344")&.id,
#   mother_id: KepplerCattle::Cow.find_by(serie_number: "55667788")&.id
# )
# actual_weight = Faker::Number.decimal(2)
# KepplerCattle::Weight.create!(
#   user_id: 1,
#   cow_id: cow&.id,
#   weight: (50.05 * 1),
#   gained_weight: 26.04.nil? ? 0 : ((50.05 * 1) - 24.50),
#   average_weight: 26.04.nil? ? 0 : (((50.05 * 1) - 24.50) / cow.days),
#   corporal_condition_id: KepplerCattle::CorporalCondition.find_by(name: row[18]),
#   observations: Faker::Lorem.paragraph
# )

# KepplerCattle::Activity.create!(
#   active: true,
#   cow_id: cow&.id,
#   observations: Faker::Lorem.paragraph
# )

# farm = KepplerFarm::Farm.all.sample
# KepplerCattle::Location.create!(
#   user_id: 1,
#   cow_id: cow&.id,
#   farm_id: farm&.id,
#   # strategic_lot_id: farm.strategic_lots.sample&.id
# )
# puts "\n# ===> Hijo creado\n\n\n"

# puts "\n# ===> Arbol genealogico creado\n\n\n"
