# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    association :user
  end
end
