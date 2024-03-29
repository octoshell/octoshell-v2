class ProjectSynchronizer
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(project_id)
    project = Core::Project.find(project_id)
    project.accesses.each(&:synchronize!)
  end
end
