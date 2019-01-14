unless ( File.basename($0) == 'rake')
  Wiki.engines_links = {
  	create_organization: Wiki::Page.where("url LIKE ?", '%organization%')
  }
end
