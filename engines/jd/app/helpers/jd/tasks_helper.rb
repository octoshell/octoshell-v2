module Jd
  module TasksHelper
    def format_float_or_nil(value)
      if value.nil?
        return ""
      else
        return "%.1f" % value
      end
    end
  end
end
