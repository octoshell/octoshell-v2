FactoryBot.define do
  factory :partition, class: 'Core::Partition' do
    association :cluster
    sequence(:name) { |n| "partition#{n}" }

    trait :default do
      default { true }
      max_running_jobs { 3 }
      max_submitted_jobs { 6 }
    end
  end
end
