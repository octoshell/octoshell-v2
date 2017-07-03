FactoryGirl.define do
 factory :project, :class => "Core::Project" do
   owner

   sequence(:title) { |n| "Octocalc_#{n}" }
   card { create_project_card }

			
		# transient do 
		# 	   	count_1 1 
		# end
	   	# proj.after_create do |l|
	   	# 	Factory(:proj,evalutor.count_1,critical_technologies: [critical_technology])
	   	# end
	   	critical_technologies { [ FactoryGirl.build(:critical_technology) ]}
		direction_of_sciences { [ FactoryGirl.build(:direction_of_science) ]}
		research_areas { [ FactoryGirl.build(:research_area) ]}
   
   

   
    
  end
end
