FactoryBot.define do
  factory :organization, :class => "Core::Organization" do
    sequence(:name) { |n| "org_#{n}" }
    city
    country { city.country }
    association :kind, factory: :organization_kind
  end
end
