Wiki.engines_links = {
	create_organization: Wiki::Page.where("url LIKE ?", '%organization%')
}
