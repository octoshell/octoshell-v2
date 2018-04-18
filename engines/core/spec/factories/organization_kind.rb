FactoryGirl.define do
  factory :organization_kind, :class => "Core::OrganizationKind" do
    sequence(:name) { |n| "kind_#{n}" }
  end
end
