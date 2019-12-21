FactoryBot.define do
  factory :profile, :class => 'Profile' do
    sequence(:first_name) { |n| "User_#{n}" }
    middle_name {'M.N.'}
    last_name {'Tester'}
    user
    # association :user, factory: :user #, strategy: :build

  end

  factory :user, :class => "User", aliases: [:owner] do
    sequence(:email) { |n| "user_#{n}@octoshell.ru" }
    password { "123456" }
    # profile
    # profile {
    #    association :profile, user_id: 1 #user.id
    # #   # prof = ::Profile.create(user: user, first_name: 'Тестер', middle_name: 'Тестерович', last_name: 'Тестеров')
    # #   # prof.save!
    # #   # prof
    # }

    after(:create) do |user|
      user.profile.first_name = 'First'
      user.profile.middle_name = 'Middle'
      user.profile.last_name = 'Last'
      user.update(activation_state: "active")
    end

    factory(:admin) do
      after(:create) do |user|
        UserGroup.create!(user: user, group: Group.find_by!( name: "superadmins" ) )
      end
    end
  end


  def create_admin(overrides = {})
    user = create(:user,overrides)
    UserGroup.create!(user: user, group: Group.find_by!( name: "superadmins" ) )
    user
  end



  factory :unactivated_user, :class => "User" do
    sequence(:email) { |n| "unactivated_user_#{n}@octoshell.ru" }
    password { "123456" }
  end
end
