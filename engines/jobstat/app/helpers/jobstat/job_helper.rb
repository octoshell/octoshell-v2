module Jobstat
  module JobHelper
    def format_float_or_nil(value)
      if value.nil?
        ""
      else
        "%.2f" % value.round(2)
      end
    end

  end
end
