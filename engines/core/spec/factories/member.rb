FactoryBot.define do
  factory :member, class: 'Core::Member' do
    association :user
    association :project
    project_access_state { 'allowed' }
  end
end
