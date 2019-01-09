FactoryBot.define do
  factory :ticket, :class => "Support::Ticket" do
    subject { 'subject' }
    message { 'message' }
    topic
   	association :reporter, factory: :user
  end
end
