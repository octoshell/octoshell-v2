FactoryBot.define do
  factory :cluster, class: 'Core::Cluster' do
    sequence(:name) { |n| "Cluster ##{n}" }
    description { 'superduperclaster' }
    host { 'localhost' }
    admin_login { 'root' }
    partitions { %w[compute pascal gpu nec].map { |name| Core::Partition.new(name: name, max_running_jobs: 3, max_submitted_jobs: 6) } }
  end
end
