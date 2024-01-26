require 'rails_helper'

RSpec.describe Task, type: :model do
	let(:user) { create(:user) }
	let(:project) { create(:project, user: user) }
	let!(:task1) { create(:task, project: project)}
	let!(:task2) { create(:task, project: project)}

	describe 'validations' do
		it 'validates presence of name' do
			task = Task.new(name: nil, description: 'Task Description', status: :todo, project: project)
			expect(task).not_to be_valid
			expect(task.errors[:name]).to include("can't be blank")
		end

		it 'validates length of name' do
			task = Task.new(name: "name"*15, description: 'Task Description', status: :todo, project: project)

			expect(task.name.length).to be > 50
			expect(task).not_to be_valid
			expect(task.errors[:name]).to include("is too long (maximum is 50 characters)")
		end

		it 'validates presence of description' do
			task = Task.new(name: 'Task Name', description: nil, status: :todo, project: project)
			expect(task).not_to be_valid
			expect(task.errors[:description]).to include("can't be blank")
		end

		it 'validates and accept only status: todo, in_progress, completed' do
			[0, 1, 2].each do |valid_status|
				task = Task.new(name: 'Task Name', status: valid_status, description: 'Task Description', project: project)

				expect(task).to be_valid
			end

			[3, 4, 5, 6].each do |invalid_status|
				expect {
					Task.new(name: 'Task Name', status: invalid_status, description: 'Task Description', project: project)
				}.to raise_error(ArgumentError, "'#{invalid_status}' is not a valid status")
			end
		end
	end

	describe 'associations' do
		it 'belongs to a project' do
			expect(project.tasks).to include(task1, task2)
		end
	end

	describe 'status enum' do
		it 'set TODO status by default' do
			task = Task.new(name: 'Task Name', description: 'Task Description', project: project)
			task.save

			expect(task).to be_valid
			expect(task.status).to eq('todo')
		end
	end
end
