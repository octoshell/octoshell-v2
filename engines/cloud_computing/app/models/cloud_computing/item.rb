module CloudComputing
  class Item < ApplicationRecord
    include CloudComputing::MassAssignment
    translates :name, :description
    belongs_to :item_kind, inverse_of: :items
    has_many :resources, inverse_of: :item, dependent: :destroy
    has_many :editable_resouces, -> { where(editable: true) },
             inverse_of: :item, dependent: :destroy, class_name: Resource.to_s
    has_many :uneditable_resouces, -> { where(editable: false) },
             inverse_of: :item, dependent: :destroy, class_name: Resource.to_s

    has_many :resources, inverse_of: :item, dependent: :destroy

    has_many :positions, inverse_of: :item, dependent: :destroy
    has_many :conditions, as: :from, dependent: :destroy
    has_many :from_conditions, class_name: Condition.to_s, as: :to, dependent: :destroy


    accepts_nested_attributes_for :resources, :positions, allow_destroy: true

    validates_translated :name, presence: true

    validates :item_kind, presence: true
    validates :identity, uniqueness: { scope: :item_kind_id }

    validates :description_ru, :description_en, presence: true, if: :new_requests

    scope :for_users, -> { where(new_requests: true) }

    scope :with_user_requests, (lambda do |user|
      joins(positions: :request).where(cloud_computing_requests: {
                                         status: 'created', created_by_id: user
                                       }).distinct

    end)

    scope :item_kind_and_descendants, (lambda do |*item_kind_ids|
      where(item_kind: ItemKind.where(id: item_kind_ids).map(&:self_and_descendants).flatten)

    end)

    def self.ransackable_scopes_skip_sanitize_args
      ransackable_scopes
    end

    def self.ransackable_scopes(_auth_object = nil)
      %i[item_kind_and_descendants]
    end

    def self.virtual_machine_items
      item_kind = ItemKind.virtual_machine_cloud_type
      return none unless item_kind

      item_kinds = item_kind.self_and_descendants
      where(item_kind: item_kinds)
    end

    def new_editable_resources
      resources.where(editable: true).map do |resource|
        ResourcePosition.new(resource: resource, value: resource.value)
      end
    end

    def fill_resources
      return unless item_kind

      ResourceKind.where(item_kind_id: item_kind.self_and_ancestors)
                  .where.not(id: resources.map(&:resource_kind_id)).each do |resource_kind|
        resource = resources.new(resource_kind: resource_kind)
        persisted? && resource.mark_for_destruction

      end
      # CloudComputing::ResourceKind.where(item_kind: @item_kind.)

    end

    def new_requests?
      new_requests
    end

    def fill_positions(user)
      request = Request.find_or_initialize_by(status: 'created', created_by: user)
      positions.each do |position|
        position.holder = request
      end
    end

    def initial_requests?
      self.class.virtual_machine_items.where(id: id).exists?
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


    # def positions_for_user(user)
    #   positions.joins_requests.where(c_r: { created_by_id: user.id,
    #                                         status: 'created' }).first
    #
    # end
    def assign_atributes_for_positions(user)
      positions.each do |position|
        next if position.persisted?

        position.holder = Request.find_or_initialize_by(status: 'created',
                                                        created_by: user)
      end
    end

    def created_positions(user)
      positions.select do |position|
        position.new_record? || position.holder.is_a?(Request) &&
          position.holder.created_by_id = user.id &&
          position.holder.status == 'created'
      end
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
