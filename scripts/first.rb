 module Pack
 # print(Package.column_names)
  print(Userver.column_names)
  #v=Version.all
  #print()
  #p=Package.all
  
 #v=Version.where(package_id: 3.to_i)
  #v.each do |pac|
  	#print(pac.r_up.to_s+" "+ pac.package_id.to_s+pac.description+pac.active.to_s+"\n")
 v=Projectsver.all
  v.each do |pac|
   #pac.destroy
  	print(pac.version_id.to_s  + "   user: " + pac.end_lic.to_s)
   
  #gr=Group.all
  #gr.each do |z|
  #	ab=Ability.create(action: "manage", subject: "packages",group_id: z.id)
  #	ab.save
  end 
end