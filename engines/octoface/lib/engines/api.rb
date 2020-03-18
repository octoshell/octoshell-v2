module Api
  extend Octoface
  octo_configure :api do
    add_ability(:manage, :api_engine, 'superadmins')
  end
end
