module CloudComputing
  class Position < ApplicationRecord
    # cloud_computing_positions
    belongs_to :item, inverse_of: :positions
    belongs_to :holder, polymorphic: true, autosave: true, inverse_of: :positions
    # belongs_to :request, -> { where(cloud_computing_positions: { holder_type: 'Request' }) },
    #                    foreign_key: 'holder_id'
    belongs_to :request, -> { where("#{Position.table_name}": { holder_type: Request.to_s }) },
                              foreign_key: 'holder_id'

    belongs_to :access, -> { where("#{Position.table_name}": { holder_type: Access.to_s }) },
                              foreign_key: 'holder_id'


    # validates :item_id, uniqueness: { scope: %i[holder_id holder_type] }
    has_many :from_links, class_name: 'CloudComputing::PositionLink', inverse_of: :from, dependent: :destroy, foreign_key: :from_id
    has_many :to_links, class_name: 'CloudComputing::PositionLink', inverse_of: :to, dependent: :destroy, foreign_key: :to_id
    has_many :nebula_identities, inverse_of: :position
    has_many :api_logs, inverse_of: :position

    has_many :resource_positions, inverse_of: :position, dependent: :destroy
    # has_many :to_positions, class_name: Position.to_s, through: :from_links, source: :to
    accepts_nested_attributes_for :from_links, :resource_positions, allow_destroy: true

    validates :amount, numericality: { greater_than: 0 }, presence: true
    validates :item, :holder, presence: true

    scope :with_user_requests, (lambda do |user|
      joins(:request).where(cloud_computing_requests: {
                              status: 'created', created_by_id: user
                            })
    end)

    # after_initialize do |position|
    #   puts position.holder.inspect.red
    # end

    def to_item_kinds
      ItemKind.joins(:to_conditions)
          .where(cloud_computing_conditions: { from_id: item.item_kind.self_and_ancestors,
                                               from_type: ItemKind.to_s })
    end

    def to_item_kinds_hash
      to_item_kinds.map { |i_k| { id: i_k.id, text: i_k.name } }
    end

    def as_json(_options = {})
      {
        id: id,
        item_name: item.name,
        amount: amount,
        to_item_kinds: to_item_kinds_hash
      }
    end


    def name
      item.name
    end

  end

end
