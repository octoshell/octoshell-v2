FactoryBot.define do
  factory :hardware_item, :class => "Hardware::Item" do
    sequence(:name_ru) { |n| "#{n}_item" }
    sequence(:name_en) { |n| "#{n}_item" }
    description_ru "description"
    description_en "description"
    association :kind, factory: :hardware_kind#, strategy: :build
  end
end
