module Pack
  module Seed
    def self.all
      
      # pack = create(:package)
      # version = create(:version, package: pack)
      # user= create(:user)

      #create(:project, owner: user)
      
    end

    def self.create(factory_name, overrides = nil)
      FactoryGirl::SeedGenerator.create(factory_name, overrides)
    end
  end
end
