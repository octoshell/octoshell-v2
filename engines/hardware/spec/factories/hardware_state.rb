FactoryBot.define do
  factory :hardware_state, :class => "Hardware::State" do
    sequence(:name_ru) { |n| "#{n}_kind" }
    sequence(:name_en) { |n| "#{n}_kind" }
    description_ru "description"
    description_en "description"
    association :kind, factory: :hardware_kind, strategy: :build
  end
end
