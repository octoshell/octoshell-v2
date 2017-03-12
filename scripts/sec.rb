#puts  Rails.root.join('engines', 'pack','config','locales')
module Pack
	
	vers=Version.find_by package_id: 1000 ,name: 'TEST NOT FOUND',description: 'zz'
	if vers
		puts  vers.name
	#	puts vers.package.name
	end
	
	
end