module CloudComputing
  class Item < ApplicationRecord
    include CloudComputing::MassAssignment
    translates :name, :description
    belongs_to :cluster, inverse_of: :items
    belongs_to :item_kind, inverse_of: :items
    has_many :resources, inverse_of: :item
    has_many :positions, inverse_of: :item
    has_many :conditions, as: :from, dependent: :destroy
    has_many :from_conditions, as: :to, dependent: :destroy


    accepts_nested_attributes_for :resources, :positions, allow_destroy: true
    # accepts_nested_attributes_for :all_conditions, allow_destroy: true

    validates_translated :name, :description, presence: true
    validates :item_kind, :cluster, presence: true

    validates :available, :max_count, numericality: { greater_than_or_equal_to: 0 },
                                     presence: true

    scope :for_users, -> { where(new_requests: true) }

    scope :with_user_requests, (lambda do |user|
      # select('*, positions from (amount)')
      joins(positions: :request).where(cloud_computing_requests: {
                                         status: 'created', created_by_id: user
                                       }).distinct

    end) # joins(positions: :requests)

    scope :item_kind_and_descendants, (lambda do |*item_kind_ids|
      # select('*, positions from (amount)')
      where(item_kind: ItemKind.where(id: item_kind_ids).map(&:self_and_descendants).flatten)

    end) # joins(positions: :requests)

    def self.ransackable_scopes(_auth_object = nil)
      %i[item_kind_and_descendants]
    end

    def self.virtual_machine_items
      item_kind = ItemKind.virtual_machine_cloud_type
      return none unless item_kind

      item_kinds = item_kind.self_and_descendants
      where(item_kind: item_kinds)
    end

    def as_json(options = {})
      resources_array = resources.map do |r|
        { name: r.resource_kind.name, value: r.value_with_measurement }
      end
      super(options).merge(name: name, description: description,
                           item_kind_name: item_kind.name,
                           resources: resources_array
                           )

    end


    def all_conditions
      if conditions.any?
        conditions
      else
        Condition.where(from: item_kind.self_and_ancestors)
      end
    end

    def requested(user)
      positions.joins_requests.where(c_r:
        { created_by_id: user.id, status: 'created' }).first&.amount
    end

    def find_positions_for_user(user)
      positions.with_user_requests(user)
    end

    # def positions_for_user(user)
    #   positions.joins_requests.where(c_r: { created_by_id: user.id,
    #                                         status: 'created' }).first
    #
    # end

    def find_or_build_positions_for_user(user)
      find_positions_for_user(user)
    end

    # def update_or_create_positions(user, params)
    #   position = find_positions_for_user(user)
    #   unless position
    #     request = Request.find_or_initialize_by(status: 'created', created_by: user)
    #     position = positions.new(holder: request)
    #   end
    #   position.assign_attributes(params)
    #   position
    #
    #     # cloud_computing_positions: { item: item })
    #   # positions.new(params) do
    #   #
    #   # end find_position_for_user(user)
    # end
     # def self.last_position
     #   order(position: :desc).first&.position || -1
     # end

  end
end
