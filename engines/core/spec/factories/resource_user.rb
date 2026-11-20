FactoryBot.define do
  factory :core_resource_user, class: 'Core::ResourceUser' do
    association :access, factory: :core_access
    member { email.present? ? nil : association(:member, project: access.project) }
  end
end
