class Seed
  def self.all
    create(:critical_technology)
    create(:direction_of_science)
    create(:research_area)
  end
  def self.create(factory_name, overrides = nil)
    FactoryBot.create(factory_name, overrides)
  end
end
