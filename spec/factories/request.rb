FactoryBot.define do
  factory :request, :class => "Core::Request" do
    project
    cluster
  end
end
