# frozen_string_literal: true

module Api
  class ProjectsController < ApplicationController
    before_action :set_project, only: %i[show update destroy]
    after_action :clear_cache, only: %i[update destroy]

    def index
      projects = current_user.projects.includes(:tasks)
      render json: projects, include: :tasks
    end

    def show
      render json: @project
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
      if @project.update(project_params)
        render json: @project
      else
        render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @project.destroy
      head :no_content
    end

    private

    def project_params
      params.require(:project).permit(:name, :description)
    end

    def set_project
      @project = QueryCaching.new(current_user, params[:id]).perform_project
    end

    def clear_cache
      Rails.cache.delete("project_#{@project.id}")
    end
  end
end
