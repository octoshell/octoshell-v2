
def create_project_card
  ru = [:name, :driver, :strategy, :objective, :impact, :usage]
  en = [:en_name, :en_driver, :en_strategy, :en_objective, :en_impact,
      :en_usage]
  all = ru | en
  attributes = Hash[all.map{ |key| [key,"test"]  }]
  Core::ProjectCard.new(attributes)
end
FactoryBot.define do
 factory :project, :class => "Core::Project" do
  owner
  sequence(:title) { |n| "Octocalc_#{n}" }
  card { create_project_card }
  #critical_technologies { [FactoryBot.build(:critical_technology)] }
  #direction_of_sciences { [FactoryBot.build(:direction_of_science)] }
  #research_areas { [FactoryBot.build(:research_area)] }
  critical_technologies {[build(:critical_technology)]}
  direction_of_sciences {[build(:direction_of_science)]}
  research_areas {[build(:research_area)]}
  kind { build(:project_kind) }
  # after(:create) do |proj|
  #   create_list(:critical_technologies, 1, project: [proj])
  #   create_list(:direction_of_sciences, 1, project: [proj])
  #   create_list(:research_areas, 1, project: [proj])
  # end
  organization
  end
end

FactoryBot.define do
  factory :critical_technology, :class => "Core::CriticalTechnology" do
    sequence(:name_ru) { |n| "Технология_#{n}" }
    sequence(:name_en) { |n| "Tech_#{n}" }
    #association :project, action: :build
  end
end
FactoryBot.define do
 factory :direction_of_science, :class => "Core::DirectionOfScience" do
   sequence(:name_ru) { |n| "Направление_#{n}" }
   sequence(:name_en) { |n| "Direction_#{n}" }
 end
end

FactoryBot.define do
  factory :group_of_research_area, class: "Core::GroupOfResearchArea" do
    sequence(:name_ru) { |n| "Группа_#{n}" }
    sequence(:name_en) { |n| "Group#{n}" }
    #association :project, action: :build
  end
end



FactoryBot.define do
  factory :research_area, :class => "Core::ResearchArea" do
    sequence(:name_ru) { |n| "Область_#{n}" }
    sequence(:name_en) { |n| "Area_#{n}" }
    group { build(:group_of_research_area) }
  end
end


FactoryBot.define do
  factory :project_kind, :class => "Core::ProjectKind" do
    sequence(:name_ru) { |n| "Тип_#{n}" }
    sequence(:name_en) { |n| "Kind_#{n}" }
    #association :project, action: :build
  end
end
