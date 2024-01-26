require 'rails_helper'

RSpec.describe User, type: :model do
	describe 'validations' do
		it 'validates presence of email' do
			user = User.new(email: nil)
			expect(user).not_to be_valid
			expect(user.errors[:email]).to include("can't be blank")
		end

		it 'validates uniqueness of email' do
			existing_user = create(:user, email: 'test@example.com')
			new_user = User.new(email: 'test@example.com')
			expect(new_user).not_to be_valid
			expect(new_user.errors[:email]).to include('has already been taken')
		end

		it 'validates presence of password' do
			user = User.new(password: nil)
			expect(user).not_to be_valid
			expect(user.errors[:password]).to include("can't be blank")
		end

		it 'validates length of password' do
			user = User.new(password: '1234')
			expect(user).not_to be_valid
			expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
		end
	end

	describe 'associations' do
		let(:user) { create(:user) }
		let(:project) { create(:project, user: user) }
		let!(:task1) { create(:task, project: project)  }
		let!(:task2) { create(:task, project: project)  }

		it 'has many projects' do
			expect(user.projects).to include(project)
		end

		it 'has many tasks through projects' do
			expect(user.tasks).to include(task1, task2)
		end
	end

	describe 'authentication token' do
		it 'generates a unique authentication token' do
			user = create(:user)
			expect(user.authentication_token).to be_present
		end

		it 'ensures the uniqueness of the authentication token' do
			existing_user = create(:user)
			expect {
				new_user = create(:user, authentication_token: existing_user.authentication_token)
				new_user.save
			}.to raise_error(ActiveRecord::RecordNotUnique,
											 /duplicate key value violates unique constraint "index_users_on_authentication_token"/)
		end
	end
end
