FactoryBot.define do
  factory :session, :class => "Sessions::Session" do
    sequence(:description_ru) { |n| "word_#{n}" }
    sequence(:description_en) { |n| "word_#{n}" }
    sequence(:motivation_ru) { |n| "word_#{n}" }
    sequence(:motivation_en) { |n| "word_#{n}" }
    receiving_to { Date.tomorrow.to_s }
  end
end
