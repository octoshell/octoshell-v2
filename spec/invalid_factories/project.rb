FactoryBot.define do
  factory :project, :class => "Core::Project" do
    owner

    title "Octocalc"
    description "Calculate All Things"
  end
end
