class ProjectSynchronizer
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(project_id)
    project = Core::Project.find(project_id)
    project.accesses.find_each do |access|
      AccessSynchronizer.perform_async(access.id)
    end
  end
end
