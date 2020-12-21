module CloudComputing
  class ApiLog < ApplicationRecord
    belongs_to :nebula_identity, inverse_of: :api_logs
    belongs_to :position, inverse_of: :api_logs

  end
end
