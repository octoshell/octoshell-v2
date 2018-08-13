module ModelTranslation
  module LightTranslates
    def light_translates(*attributes)
      include Attributes.new(*attributes)
    end
  end
end
ActiveRecord::Base.extend ModelTranslation::LightTranslates
