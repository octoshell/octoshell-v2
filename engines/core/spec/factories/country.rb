FactoryBot.define do
  factory :country, :class => "Core::Country" do
    sequence(:title_ru) { |n| "РФ_#{n}" }
    sequence(:title_en) { |n| "RF_#{n}" }
  end
end
