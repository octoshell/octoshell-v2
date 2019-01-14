FactoryBot.define do
  factory :topic, :class => "Support::Topic" do
    sequence(:name_ru) { |n| "name_#{n}" }
		sequence(:name_en) { |n| "name_#{n}" }
  end
end
