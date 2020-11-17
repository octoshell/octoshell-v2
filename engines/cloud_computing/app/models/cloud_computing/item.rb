module CloudComputing
  class Item < ApplicationRecord
    translates :name, :description
    belongs_to :cluster, inverse_of: :items
    belongs_to :item_kind, inverse_of: :items
    has_many :resources, inverse_of: :item
    has_many :positions, inverse_of: :item

    accepts_nested_attributes_for :resources, allow_destroy: true
    validates_translated :name, :description, presence: true
    validates :item_kind, :cluster, presence: true

    validates :available, :max_count, numericality: { greater_than_or_equal_to: 0 },
                                     presence: true

    scope :for_users, -> { where(new_requests: true) }

    def requested(user)
      positions.joins_requests.where(c_r:
        { created_by_id: user.id, status: 'created' }).first&.amount
    end

    def find_position_for_user(user)
      positions.joins_requests.where(c_r: { created_by_id: user.id,
                                            status: 'created' }).first
    end

    # def positions_for_user(user)
    #   positions.joins_requests.where(c_r: { created_by_id: user.id,
    #                                         status: 'created' }).first
    #
    # end

    def find_or_build_for_user(user)
      find_position_for_user(user) || positions.new
    end

    def update_position(user, params)
      position = find_position_for_user(user)
      unless position
        request = Request.find_or_initialize_by(status: 'created', created_by: user)
        position = positions.new(holder: request)
      end
      position.assign_attributes(params)
      position

        # cloud_computing_positions: { item: item })
      # positions.new(params) do
      #
      # end find_position_for_user(user)
    end
     # def self.last_position
     #   order(position: :desc).first&.position || -1
     # end

  end
end
