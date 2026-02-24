FactoryBot.define do
  factory :resource_control, class: 'Core::ResourceControl' do
    association :access, factory: :core_access
    started_at { Date.current - 1.year }
    after(:build) do |resource_control|
      Core::QuotaKind.find_or_create_by!(api_key: 'node_hours', name_ru: 'Node hours') do |k|
        resource_control.resource_control_fields.build(quota_kind: k, limit: 1000)
      end
      if resource_control.queue_accesses.empty?
        resource_control.queue_accesses.build(
          partition: resource_control.access.cluster.partitions.first,
          access: resource_control.access
        )
      end
    end
  end
  factory :core_access, class: 'Core::Access' do
    project
    cluster
    after(:create) do |access|
      [0..1, 2..2, 3..3].each do |range|
        create(:resource_control, access: access,
                                  queue_accesses: access.cluster.partitions[range].map do |partition|
                                    Core::QueueAccess.new(partition: partition, access: access)
                                  end)
      end
    end
  end
end
