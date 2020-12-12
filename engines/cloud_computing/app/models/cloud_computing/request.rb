module CloudComputing
  class Request < ApplicationRecord
    include AASM
    include ::AASM_Additions
    # belongs_to :configuration, inverse_of: :requests
    belongs_to :for, polymorphic: true
    belongs_to :created_by, class_name: 'User'
    has_many :positions, as: :holder
    has_many :left_positions, ->{ left_joins(:to_links).where(cloud_computing_position_links: {id: nil})},
      as: :holder, class_name: Position.to_s

    accepts_nested_attributes_for :left_positions, allow_destroy: true

    # validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :for, presence: true, unless: :created?
    # validates :uniqueness, presence: true, unless: :created?
    validates :status, uniqueness: { scope: %i[created_by_id] }, if: :created?

    validate do
    end


    def linked_item_kinds
      kinds = ItemKind.virtual_machine_cloud_type&.self_and_descendants || []

      rel = ItemKind.joins(items: :positions)
              .where(cloud_computing_positions: { holder_id: id,
                                                  holder_type: Request.to_s  })
              .map(&:self_and_ancestors).flatten.uniq(&:id)
              .select("")


    end

    # scope request ->

    aasm :state, column: :status do
      state :created, initial: true
      state :sent
      state :approved
      state :refused
      state :cancelled
      event :to_sent do
        transitions from: :created, to: :sent do
          guard do
            self.for && positions.exists?
          end
        end
      end
      event :cancel do
        transitions from: %i[created sent], to: :cancelled
      end


    end



  end
end
