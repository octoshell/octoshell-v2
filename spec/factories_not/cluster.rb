FactoryGirl.define do
  factory :cluster, :class => "Core::Cluster" do
    sequence(:name) { |n| "Cluster ##{n}" }
    description "supermegaclaster"
    host "localhost"
    admin_login "root"
  end
end
