require "perf/engine"
require "perf/settings" if defined?(Octoface)

module Perf
  # Your code goes here...
  ::Octoface::Hook.add_hook(:sessions, "perf/hooks/sessions_admin_reports_show",
                            :sessions, :admin_reports_show)

end
