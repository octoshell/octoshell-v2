FactoryBot.define do
  factory :options_category, :class => "Pack::OptionsCategory" do
	    sequence(:category) { |n| "#{n}_category" }
    
  end
end
