FactoryBot.define do
  factory :organization_department, :class => "Core::OrganizationDepartment" do
    sequence(:name) { |n| "dep_#{n}" }
    organization
  end
end
