def create_project_card
	ru = [:name, :driver, :strategy, :objective, :impact, :usage]
    en = [:en_name, :en_driver, :en_strategy, :en_objective, :en_impact,
      :en_usage]

    all = ru | en

    attributes = Hash[all.map{ |key| [key,"test"]  }]


    Core::ProjectCard.new(attributes)

end

def create_project(overrides = {})
	create(:project,( {direction_of_sciences: [Core::DirectionOfScience.first],
		research_areas: [Core::ResearchArea.first],critical_technologies: [Core::CriticalTechnology.first]
		}.merge overrides ) )
end
 
def create_admin(overrides = {})
	user = create(:user,overrides)
	UserGroup.create!(user: user,group: Group.find_by!( name: "superadmins" ) )
	user
end
