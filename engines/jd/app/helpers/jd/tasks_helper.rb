module Jd
  module TasksHelper
    def format_float_or_nil(value)
      if value.nil?
        return ""
      else
        return "%.2f" % value.round(2)
      end
    end
  end
end
