module CloudComputing
  class Request < ApplicationRecord
    include AASM
    include ::AASM_Additions
    include Holder
    belongs_to :created_by, class_name: 'User'
    belongs_to :access, dependent: :destroy, inverse_of: :requests
    validates :status, uniqueness: { scope: %i[created_by_id] }, if: :created?

    validate do
      # puts 'AAA'.green
      # # puts positions.map(&:item_id).uniq.inspect.red
      # puts left_positions.sum(&:amount).inspect.red
      # puts positions.sum(&:amount).inspect.red
      #
      # puts 'BBB'.green

      # positions.select(&:)
    end


    def linked_item_kinds
      kinds = TemplateKind.virtual_machine_cloud_type&.self_and_descendants || []

      rel = TemplateKind.joins(items: :positions)
              .where(cloud_computing_positions: { holder_id: id,
                                                  holder_type: Request.to_s  })
              .map(&:self_and_ancestors).flatten.uniq(&:id)
              .select("")


    end

    # scope request ->

    aasm(:status, column: :status) do
      state :created, initial: true
      state :sent
      state :approved
      state :refused
      state :cancelled
      event :to_sent do
        transitions from: :created, to: :sent do
          guard do
            self.for && items.exists? && items_filled?
          end
        end
      end

      event :approve do
        transitions from: :sent, to: :approved
      end

      event :refuse do
        transitions from: :sent, to: :refused
      end


      event :cancel do
        transitions from: %i[created sent approved], to: :cancelled
      end
    end



  end
end
