module Hardware
  extend Octoface
  octo_configure :hardware do
    add_ability(:manage, :hardware, 'superadmins')
  end
end
