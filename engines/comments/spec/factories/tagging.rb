FactoryBot.define do
  factory :tagging, :class => "Comments::Tagging" do
    # sequence(:text) { |n| "context_#{n}" }
   	user
   	association :attachable, factory: :user
    association :tag, factory: :tag


  end
end
