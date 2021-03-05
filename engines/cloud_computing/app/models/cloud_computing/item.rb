module CloudComputing
  class Item < ApplicationRecord
    # cloud_computing_items
    belongs_to :template, inverse_of: :items
    belongs_to :holder, polymorphic: true, autosave: true, inverse_of: :items
    belongs_to :item_in_access, class_name: 'CloudComputing::Item',
                                foreign_key: :item_id

    has_many :item_in_requests, class_name: 'CloudComputing::Item',
                              foreign_key: :item_id


    belongs_to :request, -> { where("#{Item.table_name}": { holder_type: Request.to_s }) },
                              foreign_key: 'holder_id'

    belongs_to :access, -> { where("#{Item.table_name}": { holder_type: Access.to_s }) },
                              foreign_key: 'holder_id'


    has_many :from_links, class_name: 'CloudComputing::ItemLink', inverse_of: :from, dependent: :destroy, foreign_key: :from_id
    has_many :to_links, class_name: 'CloudComputing::ItemLink',
                        inverse_of: :to, dependent: :destroy, foreign_key: :to_id,
                        autosave: true
    has_many :from_items, class_name: Item.to_s,
                              through: :from_links, source: :to
    has_one :virtual_machine, inverse_of: :item
    has_many :api_logs, inverse_of: :item

    has_many :resource_items, inverse_of: :item, dependent: :destroy

    accepts_nested_attributes_for :from_links, :resource_items, :from_items, allow_destroy: true
    validates_associated :resource_items

    validates :template, :holder, presence: true

    scope :with_user_requests, (lambda do |user|
      joins(:request).where(cloud_computing_requests: {
                              status: 'created', created_by_id: user
                            })
    end)

    # validate do
    #   errors.add(:holder, :invalid)
    # end
    # after_initialize do |item|
    #   puts item.holder.inspect.red
    # end

    def to_item_kinds
      TemplateKind.joins(:to_conditions)
          .where(cloud_computing_conditions: { from_id: item.item_kind.self_and_ancestors,
                                               from_type: TemplateKind.to_s })
    end

    def shared_to_item_kinds
      TemplateKind.joins(:to_conditions)
          .where(cloud_computing_conditions: { from_id: item.item_kind.self_and_ancestors,
                                               from_type: TemplateKind.to_s,
                                               max: 0 })
    end

    def to_item_kinds_hash
      to_item_kinds.map { |i_k| { id: i_k.id, text: i_k.name } }
    end

    def all_resources
      (resource_items.to_a + template.uneditable_resources.to_a)
    end

    def human_resources
      all_resources.map(&:name_value)
    end

    def as_json(_options = {})
      {
        id: id,
        item_name: item.name,
        # amount: amount,
        to_item_kinds: to_item_kinds_hash
      }
    end

    def item_in_request
      item_in_requests.where(holder: holder).first
    end

    def name
      item.name
    end

  end

end
