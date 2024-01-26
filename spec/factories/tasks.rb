FactoryBot.define do
	factory :task do
		name { Faker::Lorem.word }
		description { Faker::Lorem.sentence }
		association :project
	end
end
