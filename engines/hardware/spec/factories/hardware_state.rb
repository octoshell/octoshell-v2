FactoryBot.define do
  factory :hardware_state, :class => "Hardware::State" do
    sequence(:name_ru) { |n| "#{n}_state" }
    sequence(:name_en) { |n| "#{n}_state" }
    description_ru {"description"}
    description_en {"description"}
    association :kind, factory: :hardware_kind, strategy: :build
  end
end
