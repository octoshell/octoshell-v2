FactoryBot.define do
  factory :surety, :class => "Core::Surety" do
    boss_full_name { 'Big Bossov' }
    boss_position { 'Big Bossov' }
    project
    surety_members do
      organization = create(:organization)
      user = create(:user)
      organization.employments.create!(user: user, organization: organization)
      [Core::SuretyMember.create!(user: user, organization: organization)]
    end
    author { project.owner }
  end
end
