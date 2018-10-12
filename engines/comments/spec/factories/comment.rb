FactoryBot.define do
  factory :comment, :class => "Comments::Comment" do
    sequence(:text) { |n| "context_#{n}" }
   	user
   	association :attachable, factory: :user


  end
end
