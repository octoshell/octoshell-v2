module Core
  extend Octoface
  octo_configure do
    add_ability(:manage,  :notices, 'superadmins')
    add_ability(:manage,  Core::Notice, 'superadmins')
    add_ability(:destroy, :notices, 'superadmins') # <--- does not work
  end
end

Face::MyMenu.items_for(:admin_submenu) do
  return unless can?(:manage, :notices)
  add_item('notices', t('core.notice.notices_menu'), core.admin_notices_path,
           %r{^notices})
end

Face::MyMenu.items_for(:user_submenu) do
  notices_count = Core::Notice.get_count_for_user current_user
  if notices_count.zero?
    add_item('notices', t('core.notice.notices_menu'), core.notices_path,
             %r{^notices})
  else
    add_item(
      'notices',
      t('core.notice.notices_menu_count.html', count: notices_count).html_safe,
      core.notices_path,
      %r{^notices})
  end
  # add_item('notices', t('core.notice.notices_menu'), core.notices_path,
  #          %r{^notices})
end

Core::Notice.register_def_nil_kind_handler
# Core::Notice.register_def_woldwide_handler

Core::Notice.register_kind 'jobstat' do |notice, user, params, request|
  nil
end
