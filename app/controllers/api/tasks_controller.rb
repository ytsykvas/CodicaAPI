class Api::TasksController < ApplicationController
	before_action :set_project

	def index
		tasks = @project.tasks
		render json: tasks
	end

	def show
		task = @project.tasks.find(params[:id])
		render json: task
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
		task = @project.tasks.find(params[:id])

		if task.update(task_params)
			render json: task
		else
			render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def destroy
		task = @project.tasks.find(params[:id])
		task.destroy
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

	def task_params
		params.require(:task).permit(:name, :description, :status)
	end
end
