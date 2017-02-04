@ac = Pack::Version.where(package_id: nil)

@ac.first.name

@ac.destroy_all