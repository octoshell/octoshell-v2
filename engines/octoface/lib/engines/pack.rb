module Pack
  def self.support_access_topic
    Support::Topic.find_or_create_by!(name_ru: 'Заявка на доступ к пакету',
                                      name_en: 'Request for package',
                                      parent_topic: Support::Notificator.parent_topic)
  end
  extend Octoface
  octo_configure :pack do
    add_ability(:manage, :packages, 'superadmins')
  end
end
