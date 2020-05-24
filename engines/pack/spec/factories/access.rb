FactoryBot.define do
  factory :access, class: "Pack::Access" do
    association :to, factory: :version, strategy: :create
    association :who, factory: :user, strategy: :create
    association :created_by, factory: :user, strategy: :create
    end_lic { (Date.current + 30).to_s }
  end
end
