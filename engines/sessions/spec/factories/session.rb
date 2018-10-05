FactoryBot.define do
  factory :session, :class => "Sessions::Session" do
    sequence(:description_ru) { |n| "word_#{n}" }
    sequence(:description_en) { |n| "word_#{n}" }
    sequence(:motivation_ru) { |n| "word_#{n}" }
    sequence(:motivation_en) { |n| "word_#{n}" }
  end
end
