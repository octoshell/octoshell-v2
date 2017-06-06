FactoryGirl.define do
  factory :user, :class => "User", aliases: [:owner] do
    sequence(:email) { |n| "user_#{n}@octoshell.ru" }
    password "123456"

    after(:create) do |user|
      user.update(activation_state: "active")
    end

    factory :admin do
      admin_user { seed(:admin_user) }
    end
  end

  factory :unactivated_user, :class => "User" do
    sequence(:email) { |n| "unactivated_user_#{n}@octoshell.ru" }
    password "123456"
  end
end
