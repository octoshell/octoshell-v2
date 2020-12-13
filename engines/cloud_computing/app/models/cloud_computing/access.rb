module CloudComputing
  class Access < ApplicationRecord
    include Holder
    include AASM
    include ::AASM_Additions

    belongs_to :allowed_by, class_name: 'User'
    belongs_to :user

    belongs_to :request, inverse_of: :access

    validates :for, :user, :allowed_by, presence: true
    validates :request_id, uniqueness: true

    aasm(:state) do
      state :created, initial: true
      state :pending
      state :running
      state :finished
      state :denied

      event :pend do
        transitions from: :created, to: :pending do
          guard do
            self.for && positions.exists?
          end
        end
      end

      event :run do
        transitions from: :pending, to: :running
      end

      event :finish do
        transitions from: :running, to: :finished
      end

      event :cancel do
        transitions from: %i[pending running], to: :cancelled
      end
    end

    def copy_from_request
      return unless request

      self.for = request.for
      self.user = request.created_by
      pos_hash = Hash[request.positions.map do |position|
        [
          position,
          positions.new(item_id: position.item_id, amount: position.amount)
        ]
      end]

      request.positions.each do |position|
        from_position = pos_hash[position]
        position.from_links.each do |link|
          from_position.from_links.new(to: pos_hash[link.to],
                                       amount: link.amount)
        end
      end
    end

  end
end
