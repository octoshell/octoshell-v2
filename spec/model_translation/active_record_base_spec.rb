require 'initial_create_helper'
module ModelTranslation
    class TestClass
      extend LightTranslates
      attr_accessor :title, :title_en
      light_translates :title
      def initialize(title, title_en)
        @title = title
        @title_en = title_en
      end
    end
    describe "Base" do


      describe "Base.locale_columns" do
        # it 'raises exception' do
          # expect(TestClass.locale_columns(:missing)).to raise_exception('The missing column is not passed to light_translates call')
        # end

        # it 'shows human_attribute_name' do
        #   expect(TestClass.locale_columns(:title)).to match_array [:title_en, :title_ru]
        # end

      end

      describe "Announcements.human_attribute_name" do
        # it 'does not break default human_attribute_name' do
        #   Announcement.human_attribute_name :body
        # end

        # it 'shows human_attribute_name' do
        #   I18n.locale = :ru
        #   body = Announcement.human_attribute_name :body
        #   expect(Announcement.human_attribute_name :body_en).to eq "#{body} (#{I18n.t('model_translation.en')})"
        #   I18n.locale = :en
        #   body = Announcement.human_attribute_name :body
        #   expect(Announcement.human_attribute_name :body_en).to eq "#{body} (#{I18n.t('model_translation.en')})"
        # end

      end

      describe "TestClass with full translation" do
        let(:model) { TestClass.new('текст', 'text') }
        it 'displays russian word' do
          I18n.locale = :ru
          expect(model.title).to eq 'текст'
        end

        it 'displays english word' do
          I18n.locale = :en
          expect(model.title).to eq 'text'
          expect(model.title_en).to eq 'text'
          expect(model.title_ru).to eq 'текст'
          I18n.locale = :ru
        end

      end


      it 'displays russian word when english is empty' do
        model = TestClass.new('текст', '')
        I18n.locale = :en
        expect(model.title).to eq 'текст'
        I18n.locale = :ru
      end

      it 'assigns russian word and can be saved to db' do
        model = TestClass.new('текст', '')
        I18n.locale = :en
        model.title_ru = 'изменено'
        expect(model.title).to eq 'изменено'
        expect(model.title_en).to eq ''
        I18n.locale = :ru


      end


    end
end
