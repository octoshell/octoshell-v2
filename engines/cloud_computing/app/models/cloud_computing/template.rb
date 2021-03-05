module CloudComputing
  class Template < ApplicationRecord
    include CloudComputing::MassAssignment
    translates :name, :description
    belongs_to :template_kind, inverse_of: :templates
    has_many :resources, inverse_of: :template, dependent: :destroy
    has_many :editable_resources, -> { where(editable: true) },
             inverse_of: :template, dependent: :destroy, class_name: Resource.to_s
    has_many :uneditable_resources, -> { where(editable: false) },
             inverse_of: :template, dependent: :destroy, class_name: Resource.to_s

    has_many :resources, inverse_of: :template, dependent: :destroy

    has_many :items, inverse_of: :template, dependent: :destroy
    has_many :conditions, as: :from, dependent: :destroy
    has_many :from_conditions, class_name: Condition.to_s, as: :to, dependent: :destroy


    accepts_nested_attributes_for :resources, :items, allow_destroy: true

    validates_translated :name, presence: true

    validates :template_kind, presence: true
    validates :identity, uniqueness: { scope: :template_kind_id }

    validates :description_ru, :description_en, presence: true, if: :new_requests

    scope :for_users, -> { where(new_requests: true) }

    scope :with_user_requests, (lambda do |user|
      joins(items: :request).where(cloud_computing_requests: {
                                         status: 'created', created_by_id: user
                                       }).distinct

    end)

    scope :template_kind_and_descendants, (lambda do |*template_kind_ids|
      where(template_kind: TemplateKind.where(id: template_kind_ids).map(&:self_and_descendants).flatten)

    end)

    before_save do
      resources.each(&:save!)
    end

    def self.ransackable_scopes_skip_sanitize_args
      ransackable_scopes
    end

    def self.ransackable_scopes(_auth_object = nil)
      %i[template_kind_and_descendants]
    end

    def self.virtual_machine_templates
      template_kind = TemplateKind.virtual_machine_cloud_class
      return none unless template_kind

      template_kinds = template_kind.self_and_descendants
      where(template_kind: template_kinds)
    end



    def new_editable_resources
      resources.where(editable: true).map do |resource|
        ResourceItem.new(resource: resource, value: resource.value)
      end
    end

    def fill_resources
      return unless template_kind

      ResourceKind.where(template_kind_id: template_kind.self_and_ancestors)
                  .where.not(id: resources.map(&:resource_kind_id)).each do |resource_kind|
        resource = resources.new(resource_kind: resource_kind)
        persisted? && resource.mark_for_destruction

      end
    end

    def new_requests?
      new_requests
    end

    def fill_items(user)
      request = Request.find_or_initialize_by(status: 'created', created_by: user)
      items.each do |item|
        item.holder = request
      end
    end

    def initial_requests?
      self.class.virtual_machine_templates.where(id: id).exists?
    end

    def as_json(options = {})
      resources_array = resources.map do |r|
        if r.editable
          { name: r.resource_kind.name, value: r.human_range }
        else
          { name: r.resource_kind.name, value: r.value_with_measurement }
        end
      end
      super(options).merge(name: name, description: description,
                           template_kind_name: template_kind.name,
                           resources: resources_array
                           )

    end


    def all_conditions
      if conditions.any?
        conditions
      else
        Condition.where(from: template_kind.self_and_ancestors)
      end
    end

    def requested(user)
      items.joins_requests.where(c_r:
        { created_by_id: user.id, status: 'created' }).first&.amount
    end


    # def items_for_user(user)
    #   items.joins_requests.where(c_r: { created_by_id: user.id,
    #                                         status: 'created' }).first
    #
    # end
    def assign_atributes_for_items(user)
      items.each do |item|
        next if item.persisted?

        item.holder = Request.find_or_initialize_by(status: 'created',
                                                        created_by: user)
      end
    end

    def created_items(user)
      items.select do |item|
        item.new_record? || item.holder.is_a?(Request) &&
          item.holder.created_by_id == user.id &&
          item.holder.status == 'created'
      end
    end

    # def update_or_create_items(user, params)
    #   item = find_items_for_user(user)
    #   unless item
    #     request = Request.find_or_initialize_by(status: 'created', created_by: user)
    #     item = items.new(holder: request)
    #   end
    #   item.assign_attributes(params)
    #   item
    #
    #     # cloud_computing_items: { template: template })
    #   # items.new(params) do
    #   #
    #   # end find_item_for_user(user)
    # end
     # def self.last_item
     #   order(item: :desc).first&.item || -1
     # end

  end
end
