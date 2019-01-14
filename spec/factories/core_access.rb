FactoryBot.define do
  factory :core_access, :class => "Core::Access" do
    project
    cluster
  end
end
