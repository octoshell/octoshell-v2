# module Pack
	
# 	require "no_cleaner_helper"
# 	#require "spec_helper"
# 	require 'benchmark'
	

# 	describe "left join time testing" do
		
# 		it "user has not got access, associated with package's version)" do


# 			puts Version.count	
# 			puts Core::Project.count
# 			puts User.count

# 			Sidekiq::Testing.fake! 
# 			 # build_projects_and_members 10000
				
# 			user = User.first
# 			# build_packs 15,user 
# 			puts Access.count
# 			puts Version.count
# 			puts Package.count

# 			 # create_many_accesses(User)
# 			 # create_many_accesses(Core::Project)


# 			search=Pack::PackSearch.new({type:'packages',user_access:user.id},user.id)

# 			puts "Project begin"

# 			t1 = Time.now
			 
# 			puts "end"
# 			t2 = Time.now
# 			puts delta = t2 - t1

				
# 			query = Access.preload_who.limit(15)			
# 			# query = search.get_results(Package.allowed_for_users).limit(15)
# 			t1 = Time.now
# 			query.to_a
# 			t2 = Time.now
# 			puts delta = t2 - t1
			
# 			# expect(packages).to eq( [package,package2] )
							
			
# 		end
			
	
# 	end
# end
