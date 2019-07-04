FactoryBot.define do
  factory :package, :class => "Pack::Package" do
    # name "first_package"
    sequence(:name) { |n| "#{n}_package" }

    description {"description"}

    
  end
end
