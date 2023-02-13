require 'faker'

FactoryBot.define do
  factory :tag do
    name { Faker::Hipster.word }
    sign { Faker::Lorem.multibyte }
    kind { "expenses" }
    user
  end
end