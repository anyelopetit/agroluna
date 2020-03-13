FactoryBot.define do
  factory :keppler_farm_task, class: 'KepplerFarm::Task' do
    farm_id { 1 }
    user_id { 1 }
    title { "MyString" }
    text { "MyText" }
    completed_at { "2020-03-13 14:24:35" }
  end
end
