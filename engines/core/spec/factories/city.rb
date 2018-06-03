FactoryGirl.define do
  factory :city, :class => "Core::City" do
    sequence(:title_ru) { |n| "Москва_#{n}" }
    sequence(:title_en) { |n| "Moscow_#{n}" }
    country
  end
end
