FactoryBot.define do
  factory :version, :class => "Pack::Version" do
    sequence(:name) { |n| "#{n}_version" }
    description { "description" }
    package
    # association :package, factory: :package, strategy: :build

  end
end
