# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, user:) }
  let!(:task1) { create(:task, project:) }
  let!(:task2) { create(:task, project:) }

  describe 'validations' do
    it 'validates presence of name' do
      project = Project.new(name: nil, description: 'Test description', user:)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end

    it 'validates length of name' do
      project = Project.new(name: 'a' * 51, description: 'Test description', user:)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include('is too long (maximum is 50 characters)')
    end

    it 'validates presence of description' do
      project = Project.new(name: 'Test Project', description: nil, user:)
      expect(project).not_to be_valid
      expect(project.errors[:description]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      expect(project.user.email).to eq(user.email)
    end

    it 'has many tasks' do
      expect(project.tasks.count).to eq(2)
    end
  end

  describe 'dependency with associated tasks' do
    it 'deletes a project with associated tasks' do
      user.projects.destroy(project)

      expect(user.projects.count).to eq(0)
      expect(user.tasks.count).to eq(0)
    end
  end
end
