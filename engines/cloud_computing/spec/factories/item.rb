# FactoryBot.define do
#   factory :cloud_item, class: "CloudComputing::Item" do
#     association :item_kind, factory: :cloud_item_kind, strategy: :create
#
#     # association :who, factory: :user, strategy: :create
#     # association :created_by, factory: :user, strategy: :create
#     sequence(:name) { |n| "Item #{n}" }
#     sequence(:description) { |n| "This item #{n} is awesome for your cloud" }
#     new_requests { true }
#   end
# end
