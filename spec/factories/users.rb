FactoryBot.define do
	factory :user do
		email { Faker::Internet.email }
		password { Faker::Internet.password }
		authentication_token { Devise.friendly_token }
	end
end
