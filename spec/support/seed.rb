class Seed
  def self.all
    user = create(:user)
    create(:unactivated_user)
    create(:admin)

    create(:project, owner: user)
    create(:cluster)
  end

  def self.create(factory_name, overrides = nil)
    FactoryGirl::SeedGenerator.create(factory_name, overrides)
  end
end
