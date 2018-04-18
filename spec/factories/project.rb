def create_project_card
  ru = [:name, :driver, :strategy, :objective, :impact, :usage]
  en = [:en_name, :en_driver, :en_strategy, :en_objective, :en_impact,
      :en_usage]
  all = ru | en
  attributes = Hash[all.map{ |key| [key,"test"]  }]
  Core::ProjectCard.new(attributes)
end
FactoryGirl.define do
 factory :project, :class => "Core::Project" do
  owner
  sequence(:title) { |n| "Octocalc_#{n}" }
  card { create_project_card }
  critical_technologies { [FactoryGirl.build(:critical_technology)] }
  direction_of_sciences { [FactoryGirl.build(:direction_of_science)] }
  research_areas { [FactoryGirl.build(:research_area)] }
  organization
  end
end
