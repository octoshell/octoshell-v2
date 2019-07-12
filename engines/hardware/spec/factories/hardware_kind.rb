FactoryBot.define do
  factory :hardware_kind, :class => "Hardware::Kind" do
    sequence(:name_ru) { |n| "#{n}_kind" }
    sequence(:name_en) { |n| "#{n}_kind" }
    description_ru { "description" }
    description_en { "description" }
    # association :package, factory: :package, strategy: :build
  end
end
