FactoryBot.define do
  factory :access, class: "Pack::Access" do
    association :version, strategy: :create
    association :who, factory: :user, strategy: :create
    association :created_by, factory: :user, strategy: :create
    end_lic { Date.current.to_s }
  end
end
