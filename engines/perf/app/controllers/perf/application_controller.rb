module Perf
  class ApplicationController < ::ApplicationController
    before_action :require_login
    layout 'layouts/perf/application'

  end
end
