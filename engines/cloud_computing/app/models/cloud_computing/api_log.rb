module CloudComputing
  class ApiLog < ApplicationRecord
    belongs_to :virtual_machine, inverse_of: :api_logs
    belongs_to :item, inverse_of: :api_logs

  end
end
