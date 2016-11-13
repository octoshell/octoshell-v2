 module Pack
  print(Package.column_names)
  print(Version.column_names)
  v=Version.all
  print()
  p=Package.all
 v=Version.where(package_id: 3.to_i)
  v.each do |pac|
  	print(pac.id.to_s+" "+ pac.pack_package_id.to_s+pac.description+pac.active.to_s+"\n")
  end 
end