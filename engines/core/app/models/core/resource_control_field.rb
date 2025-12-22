module Core
  class ResourceControlField < ApplicationRecord
    belongs_to :resource_control, inverse_of: :resource_control_fields
    belongs_to :quota_kind
    validates :resource_control, :quota_kind, :limit, presence: true
    validates :resource_control_id, uniqueness: { scope: :quota_kind_id }

    def stat
      "#{(cur_value || 0).round(2)} / #{limit} (#{quota_kind})"
    end

    def exceeded?
      !cur_value.nil? && cur_value >= limit
    end



  end
end
