module Wikiplus
  extend Octoface
  octo_configure :wiki do
    add_ability(:manage, :wikiplus, 'superadmins')
  end

  def self.engines_links
    {
      create_organization: Page.where("url LIKE ?", '%organization%'),
      comments_guide: Page.where("url LIKE ?", '%comments_guide%')
    }
  end
end
