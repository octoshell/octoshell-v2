module CloudComputing
  class Condition < ApplicationRecord
    enum kind: %i[required available]
    belongs_to :from, polymorphic: true
    belongs_to :to, polymorphic: true

    def positions(user)
      to.children.map(&:items).flatten.map do |item|
        item.find_position_for_user(user)
      end.compact
    end
    # validates :kind, inclusion: { in: %w[required available] }
  end
end
