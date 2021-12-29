module Perf

  extend Octoface
  octo_configure :perf do
    add_ability(:manage, :perf_experts, 'superadmins', 'experts')
    add_controller_ability(:manage, :perf_experts, 'admin/experts')
    add_routes do
      mount Perf::Engine, :at => "/perf"
    end
    after_init do
    end
  end
end
