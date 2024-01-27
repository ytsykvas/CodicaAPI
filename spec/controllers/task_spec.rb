# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:project) { create(:project, user:) }
  let(:task_params) { attributes_for(:task) }

  describe 'GET #index' do
    before { sign_in(user) }

    it 'returns a success response' do
      get :index, params: { project_id: project.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns all tasks for the project' do
      task1 = create(:task, project:, name: 'Task 1', description: 'Description 1')
      task2 = create(:task, project:, name: 'Task 2', description: 'Description 2')

      get :index, params: { project_id: project.id }

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.first['name']).to eq(task1.name)
      expect(json_response.last['name']).to eq(task2.name)
    end
  end

  describe 'GET #show' do
    before { sign_in(user) }

    it 'returns a success response' do
      task = create(:task, project:)
      get :show, params: { project_id: project.id, id: task.id }
      expect(response).to have_http_status(:success)
    end

    it 'renders JSON with the task details' do
      task = create(:task, project:, name: 'Test Task', description: 'Test Description')
      get :show, params: { project_id: project.id, id: task.id }

      json_response = JSON.parse(response.body)
      expect(json_response['name']).to eq('Test Task')
      expect(json_response['description']).to eq('Test Description')
    end
  end

  describe 'POST #create' do
    before { sign_in(user) }

    it 'creates a new task' do
      post :create, params: { project_id: project.id, task: task_params }

      expect(response).to have_http_status(:created)
      expect(Task.count).to eq(1)

      new_task = Task.first
      expect(new_task.name).to eq(task_params[:name])
      expect(new_task.description).to eq(task_params[:description])
      expect(new_task.project).to eq(project)
    end

    it 'creates a new task with a TODO status by default' do
      post :create, params: { project_id: project.id, task: task_params }

      expect(response).to have_http_status(:created)
      expect(Task.count).to eq(1)

      new_task = Task.first
      expect(new_task.name).to eq(task_params[:name])
      expect(new_task.status).to eq('todo')
    end

    it 'returns errors for invalid task creation' do
      invalid_params = { task: { name: '', description: '', status: '' } }
      post :create, params: { project_id: project.id, task: invalid_params }

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Name can't be blank", "Description can't be blank")
    end
  end

  describe 'PUT #update' do
    before { sign_in(user) }
    let!(:task) { create(:task, project:) }

    it 'updates the requested task' do
      updated_params = { task: { name: 'Updated Task', description: 'Updated Description', status: 'in_progress' } }
      put :update, params: { project_id: project.id, id: task.id }.merge(updated_params)

      expect(response).to have_http_status(:success)

      task.reload
      expect(task.name).to eq('Updated Task')
      expect(task.description).to eq(task.description)
      expect(task.status).to eq('in_progress')
    end

    it 'returns errors for invalid task update' do
      # task = create(:task, project: project, name: 'Existing Task', description: 'Existing Description')

      invalid_params = { task: { name: '', description: '', status: '' } }
      put :update, params: { project_id: project.id, id: task.id }.merge(invalid_params)

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Name can't be blank", "Description can't be blank",
                                                 "Status can't be blank")
    end

    it 'clear cache with with updated task' do
      QueryCaching.new(user, task.id, project).perform_task

      delete :destroy, params: { project_id: project.id, id: task.id }

      expect(Rails.cache.read("task_#{task.id}")).to be_nil
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in(user) }
    let!(:task) { create(:task, project:) }
    it 'destroys the requested task' do
      delete :destroy, params: { project_id: project.id, id: task.id }

      expect(response).to have_http_status(:no_content)
      expect(Task.count).to eq(0)
    end

    it 'clear cache with with deleted task' do
      QueryCaching.new(user, task.id, project).perform_task

      delete :destroy, params: { project_id: project.id, id: task.id }

      expect(Rails.cache.read("task_#{task.id}")).to be_nil
    end
  end

  describe 'GET #tasks_by_status' do
    before { sign_in(user) }

    it 'returns tasks with the required status' do
      task1 = create(:task, project:, status: 0)
      task2 = create(:task, project:, status: 1)

      get :tasks_by_status, params: { project_id: project.id, status: 'todo' }

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['status']).to eq('todo')
      expect(json_response.first['id']).to eq(task1.id)
      expect(json_response.any? { |task| task['id'] == task2.id }).to be_falsey
    end
  end
end
