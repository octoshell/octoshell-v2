FactoryGirl.define do
  factory :access, :class => "Pack::Access" do
    # name "first_package"
    version
    association :who, factory: :user
    association :created_by, factory: :user
    end_lic AmericanDate.current.to_s
    
  end
end
