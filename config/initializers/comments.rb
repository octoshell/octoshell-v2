# unless ( File.basename($0) == 'rake')
  Comments.inline_types = %w[png jpeg jpg bmp gif]
# end
module Comments
  extend Octoface
  octo_configure do
  end

end

Face::MyMenu.items_for(:user_submenu) do
  add_item('comments', t("user_submenu.comments"), comments.index_all_comments_path, /^comments/)
end


Face::MyMenu.items_for(:admin_submenu) do
  if User.superadmins.include? current_user
    add_item('comments', t('admin_submenu.comments'),
             comments.edit_admin_group_classes_path,
             %r{comments/admin})
  end
end
