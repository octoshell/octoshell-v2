
  puts  'AAAAAAAA' + ::Core::Project.class.to_s
  if ::Support::Topic.find_by name: I18n.t('integration.support_theme_name')
    puts ::Support::Topic.create!(name: I18n.t('integration.support_theme_name')).id
    ::Support::Topic.find_by name: I18n.t('integration.support_theme_name').destroy
  end


 