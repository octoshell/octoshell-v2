FactoryBot.define do
  factory :notice, class: 'Core::Notice' do
    message { 'You are notified'}
    category { 0 }
    active { true }
  end
end
