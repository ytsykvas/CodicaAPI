# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ProjectsController, type: :controller do
  before { sign_in(user) }
  let(:user) { create(:user) }
  let!(:project) { create(:project, user:) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it 'returns all projects' do
      project2 = create(:project, user:)

      get :index

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.first['name']).to eq(project.name)
      expect(json_response.last['name']).to eq(project2.name)
    end

    it 'returns all projects with included tasks' do
      task = create(:task, project:)

      get :index

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['name']).to eq(project.name)
      expect(json_response.first['tasks'].length).to eq(1)
      expect(json_response.first['tasks'].first['name']).to eq(task.name)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: project.id }
      expect(response).to have_http_status(:success)
    end

    it 'renders JSON with the project details' do
      get :show, params: { id: project.id }

      json_response = JSON.parse(response.body)
      expect(json_response['name']).to eq(project.name)
      expect(json_response['description']).to eq(project.description)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { project: { name: 'New Project', description: 'New Description' } } }
    let(:invalid_params) { { project: { name: '', description: '' } } }

    it 'creates a new project' do
      post :create, params: valid_params

      expect(response).to have_http_status(:created)
      expect(Project.count).to eq(2)
      expect(Project.last.name).to eq(valid_params[:project][:name])
      expect(Project.last.description).to eq(valid_params[:project][:description])
      expect(Project.last.user).to eq(user)
    end

    it 'returns errors for invalid project creation' do
      post :create, params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Name can't be blank", "Description can't be blank")
    end
  end

  describe 'PUT #update' do
    let(:valid_params) { { project: { name: 'New Project', description: 'New Description' } } }
    let(:invalid_params) { { project: { name: '', description: '' } } }
    let(:user) { create(:user) }
    let!(:project) { create(:project, user:) }

    it 'updates the requested project' do
      put :update, params: { id: project.id }.merge(valid_params)

      expect(response).to have_http_status(:success)

      project.reload
      expect(project.name).to eq('New Project')
      expect(project.description).to eq('New Description')
    end

    it 'returns errors for invalid project update' do
      put :update, params: { id: project.id }.merge(invalid_params)

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Name can't be blank", "Description can't be blank")
    end
  end

  describe 'DELETE #destroy' do
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
