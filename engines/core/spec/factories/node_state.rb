FactoryBot.define do
  factory :node_state, class: 'Core::NodeState' do
    association :node
    state { 'idle' }
    reason { nil }
    state_time { 1.hour.ago }
  end
end
