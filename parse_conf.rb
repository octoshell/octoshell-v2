config = YAML.load_file('lim_conf.yml')
CLUSTER_ID = 5
quota = Core::QuotaKind.find_by_api_key!('node_hours')
Core::ResourceControl.all.map(&:destroy!)
Core::ResourceControlField.all.map(&:destroy!)
Core::QueueAccess.all.map(&:destroy!)




ActiveRecord::Base.transaction do
  Core::Partition.where(cluster_id: CLUSTER_ID).each do |partition|
    partition.update!(max_running_jobs: 3, max_submitted_jobs: 6)
  end
  config.values.each do |h|
    next unless h[:partitions].present? &&  h[:start].present?

    project_ids = (Core::Member.where(login: h[:logins]).map(&:project_id) |
                   Core::RemovedMember.where(login: h[:logins]).map(&:project_id)).uniq
    raise "not one  project" if project_ids.count != 1

    project_id = project_ids.first

    access = Core::Access.find_by(cluster_id: CLUSTER_ID, project_id: project_id)

    next unless access

    r_c = Core::ResourceControl.create!(
      access: access,
      started_at: h[:start]
    )

    h[:partitions].each do |part_name|
      puts part_name.inspect.green
      part = Core::Partition.find_by!(cluster_id: CLUSTER_ID, name: part_name)
      r_c.queue_accesses.create!(partition: part, access: access,
                                 max_running_jobs: 3, max_submitted_jobs: 6)
    end
    r_c.resource_control_fields.create!(
      quota_kind: quota,
      limit: h[:lim]
    )
    r_c.save!
  end
  puts Core::ResourceControl.last.inspect
end
