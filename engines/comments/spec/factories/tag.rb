FactoryBot.define do
  factory :tag, :class => "Comments::Tag" do
    sequence(:name) { |n| "name_#{n}" }
  end
end
