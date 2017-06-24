module PackHelpers
def access_with_status overrides=nil 
	access=FactoryGirl.build(:access,overrides)	
	access.save
	access
end

end