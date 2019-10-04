FactoryBot.define do
  factory :field, :class => "Support::Field" do
    sequence(:name_ru) { |n| "name_#{n}" }
		sequence(:name_en) { |n| "name_#{n}" }
    topics {[FactoryBot.create(:topic)]}
  end
end
