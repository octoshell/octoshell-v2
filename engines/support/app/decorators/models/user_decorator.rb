User.class_eval do
  # Prevent multiple definition of HABTM association in development mode
  unless reflect_on_association(:subscribed_tickets)
    has_many :tickets, class_name: 'Support::Ticket', foreign_key: :reporter_id, inverse_of: :reporter,
                       dependent: :destroy
    has_and_belongs_to_many :subscribed_tickets, class_name: 'Support::Ticket',
                                                 join_table: :support_tickets_subscribers, inverse_of: :subscribers, dependent: :destroy
    has_many :user_topics, class_name: 'Support::UserTopic',
                           inverse_of: :user, dependent: :destroy
    has_many :available_topics, through: :user_topics, source: :topic, class_name: 'Support::Topic'
    has_many :available_tickets, through: :available_topics, source: :tickets, class_name: 'Support::Ticket'
  end
end # if Support.user_class
