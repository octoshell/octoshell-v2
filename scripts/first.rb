 module Pack

  @ac= Access.new
  @ac.version= Version.first
  @ac.who= User.first
  @ac.user=User.first
  if (!@ac.save)
    print("error")
  end
  print(@ac.who_type)
  Access.first.delete


  @ac = Access.all
  if !@ac
    print("NO")
  end
  @ac.destroy_all

  @ac = Access.all
  if !@ac
    print("NO")
  end
  

 # print(Package.column_names)

   #print(Clusterver.new.methods)#.include?(:javax))
  #v=Version.all
  #print()
  #p=Package.all
  
 #v=Version.where(package_id: 3.to_i)
  #v.each do |pac|
  	#print(pac.r_up.to_s+" "+ pac.package_id.to_s+pac.description+pac.active.to_s+"\n")
 
   
  #gr=Group.all
  #gr.each do |z|
  #	ab=Ability.create(action: "manage", subject: "packages",group_id: z.id)
  #	ab.save
  
end