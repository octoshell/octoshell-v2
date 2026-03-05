FactoryBot.define do
  factory :partition, class: 'Core::Partition' do
    association :cluster
    sequence(:name) { |n| "partition#{n}" }
  end
end
