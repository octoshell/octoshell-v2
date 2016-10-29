FactoryGirl.define do
  factory :project, :class => "Core::Project" do
    owner

    name "Octocalc"
    description "Calculate All Things"
  end
end
