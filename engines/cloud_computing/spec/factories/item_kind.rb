FactoryBot.define do
  factory :item_kind, class: "CloudComputing::ItemKind" do
    # association :to, factory: :version, strategy: :create
    # association :who, factory: :user, strategy: :create
    # association :created_by, factory: :user, strategy: :create
    sequence(:name) { |n| "item_kind_#{n}" }
  end
end
