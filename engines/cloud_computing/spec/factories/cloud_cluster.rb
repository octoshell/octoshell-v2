FactoryBot.define do
  factory :cloud_cluster, class: "CloudComputing::Cluster" do
    core_cluster { Core::Cluster.first }
    description { "Proxy object for core cluster" }
  end
end
