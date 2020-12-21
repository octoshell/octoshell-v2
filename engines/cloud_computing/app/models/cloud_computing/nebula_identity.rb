module CloudComputing
  class NebulaIdentity < ApplicationRecord
    belongs_to :position, inverse_of: :nebula_identities
    has_many :api_logs, inverse_of: :nebula_identity

    validates :identity, uniqueness: true
  end
end
