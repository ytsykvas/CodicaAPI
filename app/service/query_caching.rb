class QueryCaching
	def initialize(user, param, project = nil)
		@user = user
		@param = param
		@project = project
	end

	def perform_project
		perform(project_key) do
			@user.projects.find_by(id: @param)
		end
	end

	def perform_task
		perform(task_key) do
			@project.tasks.find(@param) if @project.present?
		end
	end

	private

	def perform(key)
		if check_key(key).present?
			result = Rails.cache.read(key)
		else
			result = yield
			update_cache(key, result) if result
			result = check_key(key)
		end
		result
	end

	def check_key(key)
		Rails.cache.read(key)
	end

	def update_cache(key, data)
		Rails.cache.write(key, data, expires_in: 5.minutes)
	end

	def project_key
		"project_#{@param}"
	end

	def task_key
		"task_#{@param}"
	end
end
