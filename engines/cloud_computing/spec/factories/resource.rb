# FactoryBot.define do
#   factory :cloud_resource, class: "CloudComputing::Resource" do
#     association :resource_kind, factory: :cloud_resource_kind, strategy: :create
#
#     association :item, factory: :cloud_item, strategy: :create
#     # association :created_by, factory: :user, strategy: :create
#     sequence(:value) { |n| n * 100 }
#     # sequence(:description) { |n| "This item #{n} is awesome for your cloud" }
#     new_requests { true }
#   end
# end
