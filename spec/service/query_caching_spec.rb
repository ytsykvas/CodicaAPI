# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QueryCaching, type: :service do
  let(:user) { create(:user) }
  let(:project) { create(:project, user:) }
  let!(:task) { create(:task, project:) }

  describe '#perform_project' do
    it 'caches and retrieves the project' do
      caching = QueryCaching.new(user, project.id)
      cached_project = caching.perform_project

      expect(cached_project).to eq(project)
      expect(Rails.cache.read("project_#{project.id}")).to eq(project)
    end

    it 'returns nil if the project is not found' do
      non_existent_project_id = 999
      caching = QueryCaching.new(user, non_existent_project_id)

      expect(caching.perform_project).to be_nil
      expect(Rails.cache.read("project_#{non_existent_project_id}")).to be_nil
    end
  end

  describe '#perform_task' do
    it 'caches and retrieves the task' do
      caching = QueryCaching.new(user, task.id, project)
      cached_task = caching.perform_task

      expect(cached_task).to eq(task)
      expect(Rails.cache.read("task_#{task.id}")).to eq(task)
    end

    it 'returns nil if the task is not found' do
      non_existent_task_id = 999
      caching = QueryCaching.new(user, non_existent_task_id, project)

      expect { caching.perform_task }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Rails.cache.read("task_#{non_existent_task_id}")).to be_nil
    end
  end
end
