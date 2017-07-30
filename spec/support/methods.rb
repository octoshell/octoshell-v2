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

def build_projects_and_members n
	projects = []
	dir = Core::DirectionOfScience.first
	res = Core::ResearchArea.first
	crit = Core::CriticalTechnology.first
	ru = [:name, :driver, :strategy, :objective, :impact, :usage]
    en = [:en_name, :en_driver, :en_strategy, :en_objective, :en_impact,
      :en_usage]

    all = ru | en

    attributes = Hash[all.map{ |key| [key,"test"]  }]
	card = Core::ProjectCard.new(attributes)
	puts "Creating Projects"
	n.times do |i|
		
		projects << Core::Project.new(card: card,title: "proj_#{i}", critical_technologies: [crit], direction_of_sciences: [dir], 
		research_areas: [res]	)
		
	end
	puts "Projects array is ready"
	t1 = Time.now
	Core::Project.import projects,{ vaildate: false}
	t2 = Time.now
	puts delta = t2 - t1
	puts "Projects created"
	projects = []

	users = []
	members = []
	user_columns = [:email,:activation_state,:crypted_password]
	member_columns = [:project_id, :owner,:user_id]


	t1 = Time.now
	# User.import(users,{vaildate: false,timestamps: false})
	

	str =  <<-eoruby
	 INSERT INTO "users" ("email", "activation_state", "crypted_password", "access_state", "created_at", "updated_at") 
	 VALUES
	eoruby


	Core::Project.all.ids.each do |id|
		str <<"('us#{id}_@octoshell.ru', 'active', '123456', 'active', '2017-07-27 12:59:50.604000', '2017-07-27 12:59:50.604000')," 

		members << [id, true]	
		
	end
	str = str[0..-2]
	str << "RETURNING 'id'"
	t2 = Time.now
	puts delta = t2 - t1
	puts "users ready"
	t1 = Time.now
	ActiveRecord::Base.connection.execute(str)
	t2 = Time.now
	puts delta = t2 - t1
	puts User.count

	
	puts "users created"

	users = []


	i = 0
	User.limit(n).ids.each do |id|
		members[i] << id
		i+=1
	end
	puts "members ready"
	Core::Member.import member_columns,members
	puts "members created"

	
	puts Core::Project.to_s
	# create_many_accesses(User)
	# create_many_accesses(Core::Project)
	

		
end 

def create_many_accesses(relation)
	
	vs= Pack::Version.all.ids
	 vs.each do |v_id|
	 	puts v_id
		str_acc =  <<-eoruby
	 	INSERT INTO "pack_accesses" ("who_id", "who_type", "version_id","status") 
	 	VALUES
		eoruby
		relation.all.ids.each do |id|
			str_acc <<"('#{id}', '#{relation.to_s}', '#{v_id}', 'allowed')," 
		end
		
		str_acc = str_acc[0..-2]
		str_acc << "RETURNING 'id'"
		ActiveRecord::Base.connection.execute(str_acc)

	end
	

end
def create_admin(overrides = {})
	user = create(:user,overrides)
	UserGroup.create!(user: user,group: Group.find_by!( name: "superadmins" ) )
	user
end
def create_support(overrides = {})
	user = create(:user,overrides)
	UserGroup.create!(user: user,group: Group.find_by!( name: "support" ) )
	user
end