require ''
module ModelTranslation
    class TestClass
      extend LightTranslates
      attr_accessor :title_ru, :title_en
      light_translates :title
      def initialize(title_ru, title_en)
        @title_ru = title_en
        @title_en = title_en
      end
    end
    describe "Base" do


    end
end
