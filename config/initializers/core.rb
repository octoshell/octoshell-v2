Core.user_class = "::User"
module Core
  extend Octoface
  octo_configure do
    add(:project_class) { Project }
    add(:cluster_class) { Cluster }
  end
end
