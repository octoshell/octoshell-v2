FactoryBot.define do
  factory :profile, :class => 'Profile' do
    sequence(:first_name) { |n| "User_#{n}" }
    middle_name {'M.N.'}
    last_name {'Tester'}
    association :user, factory: :user #, strategy: :build
    
  end

  factory :user, :class => "User", aliases: [:owner] do
    sequence(:email) { |n| "user_#{n}@octoshell.ru" }
    password { "123456" }
    # profile {
    #    association :profile, user_id: 1 #user.id
    # #   # prof = ::Profile.create(user: user, first_name: 'Тестер', middle_name: 'Тестерович', last_name: 'Тестеров')
    # #   # prof.save!
    # #   # prof
    # }

    after(:create) do |user|
      user.update(activation_state: "active")
    end
  end

  factory :unactivated_user, :class => "User" do
    sequence(:email) { |n| "unactivated_user_#{n}@octoshell.ru" }
    password { "123456" }
  end
end
