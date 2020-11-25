module CloudComputing
  class Condition < ApplicationRecord
    enum kind: %i[required available]
    belongs_to :from, polymorphic: true
    belongs_to :to, polymorphic: true

    def positions(user)
      if to.is_a?(ItemKind)
        Item.where(item_kind: to.self_and_descendants).with_user_requests(user)
        .eager_load(:positions).map(&:positions).flatten.compact
      end
    end
    # validates :kind, inclusion: { in: %w[required available] }
  end
end
