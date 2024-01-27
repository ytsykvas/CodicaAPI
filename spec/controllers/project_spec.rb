# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ProjectsController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #index' do
    before { sign_in(user) }

    it 'returns a success response' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'returns all projects' do
      project1 = create(:project, user:, name: 'Project 1', description: 'Description 1')
      project2 = create(:project, user:, name: 'Project 2', description: 'Description 2')

      get :index

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.first['name']).to eq(project1.name)
      expect(json_response.last['name']).to eq(project2.name)
    end

    it 'returns all projects with included tasks' do
      project = create(:project, user:, name: 'Project 1', description: 'Description 1')
      task = create(:task, name: 'Task 1', project:)

      get :index

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['name']).to eq(project.name)
      expect(json_response.first['tasks'].length).to eq(1)
      expect(json_response.first['tasks'].first['name']).to eq(task.name)
    end
  end

  describe 'GET #show' do
    before { sign_in(user) }

    it 'returns a success response' do
      project = create(:project, user:)
      get :show, params: { id: project.id }
      expect(response).to have_http_status(:success)
    end

    it 'renders JSON with the project details' do
      project = create(:project, user:, name: 'Test Project', description: 'Test Description')
      get :show, params: { id: project.id }

      json_response = JSON.parse(response.body)
      expect(json_response['name']).to eq('Test Project')
      expect(json_response['description']).to eq('Test Description')
    end
  end

  describe 'POST #create' do
    before { sign_in(user) }

    it 'creates a new project' do
      project_params = { project: { name: 'New Project', description: 'New Description' } }
      post :create, params: project_params

      expect(response).to have_http_status(:created)
      expect(Project.count).to eq(1)

      new_project = Project.first
      expect(new_project.name).to eq('New Project')
      expect(new_project.description).to eq('New Description')
      expect(new_project.user).to eq(user)
    end

    it 'returns errors for invalid project creation' do
      invalid_params = { project: { name: '', description: '' } }
      post :create, params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Name can't be blank", "Description can't be blank")
    end
  end

  describe 'PUT #update' do
    before { sign_in(user) }

    it 'updates the requested project' do
      project = create(:project, user:, name: 'Old Project', description: 'Old Description')

      updated_params = { project: { name: 'Updated Project', description: 'Updated Description' } }
      put :update, params: { id: project.id }.merge(updated_params)

      expect(response).to have_http_status(:success)

      project.reload
      expect(project.name).to eq('Updated Project')
      expect(project.description).to eq('Updated Description')
    end

    it 'returns errors for invalid project update' do
      project = create(:project, user:, name: 'Existing Project', description: 'Existing Description')

      invalid_params = { project: { name: '', description: '' } }
      put :update, params: { id: project.id }.merge(invalid_params)

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Name can't be blank", "Description can't be blank")
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in(user) }
    let!(:project) { create(:project, user:) }

    it 'destroys the requested project' do
      delete :destroy, params: { id: project.id }

      expect(response).to have_http_status(:no_content)
      expect(Project.count).to eq(0)
    end

    it 'clear cache with with deleted project' do
      QueryCaching.new(user, project.id).perform_project

      delete :destroy, params: { id: project.id }

      expect(Rails.cache.read("project_#{project.id}")).to be_nil
    end
  end
end
