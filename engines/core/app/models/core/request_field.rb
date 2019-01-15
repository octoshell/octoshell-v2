module Core
  class RequestField < ActiveRecord::Base
    belongs_to :request
    belongs_to :quota_kind

    validates :request, :value, presence: true

    def to_s
      "#{quota_kind.name}: #{value} #{quota_kind.measurement}"
    end
  end
end
