class Api::TasksController < ApplicationController
	before_action :set_project
	before_action :set_task, only: [:show, :update, :destroy]

	def index
		tasks = @project.tasks
		render json: tasks
	end

	def show
		render json: @task
	end

	def create
		task = @project.tasks.build(task_params)

		if task.save
			render json: task, status: :created
		else
			render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def update
		if @task.update(task_params)
			render json: @task
		else
			render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def destroy
		@task.destroy
		head :no_content
	end

	def tasks_by_status
		tasks = @project.tasks.where(status: params[:status])
		render json: tasks
	end

	private

	def set_project
		@project = current_user.projects.find(params[:project_id])
	end

	def set_task
		@task = @project.tasks.find(params[:id])
	end

	def task_params
		params.require(:task).permit(:name, :description, :status)
	end
end
