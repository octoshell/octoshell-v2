FactoryBot.define do
  factory :context, class: 'Comments::Context' do
    sequence(:name) { |n| "name_#{n}" }
  end
end
