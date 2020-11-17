module CloudComputing
  class Position < ApplicationRecord
    belongs_to :item, inverse_of: :positions
    belongs_to :holder, polymorphic: true, autosave: true

    validates :item_id, uniqueness: { scope: %i[holder_id holder_type] }
    has_many :from_links, class_name: 'PositionLink', inverse_of: :from, dependent: :destroy
    has_many :to_links, class_name: 'PositionLink', inverse_of: :to, dependent: :destroy

    scope :joins_requests, -> { joins('INNER JOIN cloud_computing_requests AS c_r ON c_r.id = cloud_computing_positions.holder_id AND
       cloud_computing_positions.holder_type=\'CloudComputing::Request\' ') }

    validates :amount, :item, :holder, presence: true

    validate do
      if item&.max_count && amount.present? && amount > item.max_count
        errors.add :amount, 'error'
      end
    end

    def name
      item.name
    end

  end

end
