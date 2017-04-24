module Pack
 
 	
   
  
  if !Support::Topic.find_by name: I18n.t('pack.integration.support_theme_name')
     
    Access.support_access_topic_id=Support::Topic.create!(name: I18n.t('pack.integration.support_theme_name')).id
  end

end
 