Support.user_class.class_eval do
  has_many :tickets, class_name: "Support::Ticket", foreign_key: :reporter_id, inverse_of: :reporter, dependent: :destroy
  has_and_belongs_to_many :subscribed_tickets, class_name: "Support::Ticket",
                          join_table: :support_tickets_subscribers, inverse_of: :subscribers, dependent: :destroy
end if Support.user_class
