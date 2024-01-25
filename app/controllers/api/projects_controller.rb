class Api::ProjectsController < ApplicationController

	def index
		projects = current_user.projects.includes(:tasks)
		render json: projects, include: :tasks
	end

	def show
		project = current_user.projects.find(params[:id])
		render json: project
	end

	def create
		project = current_user.projects.build(project_params)

		if project.save
			render json: project, status: :created
		else
			render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def update
		project = current_user.projects.find(params[:id])

		if project.update(project_params)
			render json: project
		else
			render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def destroy
		project = current_user.projects.find(params[:id])
		project.destroy
		head :no_content
	end

	private

	def project_params
		params.require(:project).permit(:name, :description)
	end
end
