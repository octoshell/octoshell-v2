module Wikiplus
  extend Octoface
  octo_configure do
    add_ability(:manage, :wikiplus, 'superadmins')
  end

  def self.engines_links
    {
      create_organization: Page.where("url LIKE ?", '%organization%'),
      comments_guide: Page.where("url LIKE ?", '%comments_guide%')
    }
  end
end


Face::MyMenu.items_for(:admin_submenu) do
  if can? :manage, :wikiplus
    add_item('wiki', t("admin_submenu.wikiplus"),
             wikiplus.admin_pages_path, %r{admin/wikiplus})
  end
end
