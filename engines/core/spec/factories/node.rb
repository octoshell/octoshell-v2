FactoryBot.define do
  factory :node, class: 'Core::Node' do
    association :cluster
    sequence(:name) { |n| "node#{n}" }
  end
end
