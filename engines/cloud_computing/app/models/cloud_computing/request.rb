module CloudComputing
  class Request < ApplicationRecord
    include AASM
    include ::AASM_Additions
    # belongs_to :configuration, inverse_of: :requests
    belongs_to :for, polymorphic: true
    belongs_to :created_by, class_name: 'User'
    has_many :positions, as: :holder

    # validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :for, presence: true, unless: :created?
    validate do
      # if configuration && amount > configuration.available
      #   errors.add :amount, 'error'
      # end
    end

    # scope request ->

    aasm :state, column: :status do
      state :created, initial: true
      state :sent
      state :approved
      state :refused
      state :cancelled
      #after_transition on: :deliver, &:send_mails #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!FIX
    end



  end
end
