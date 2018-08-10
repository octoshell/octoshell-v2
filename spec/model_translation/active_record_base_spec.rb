require 'initial_create_helper'
module ModelTranslation
  module ActiveRecord
    class TestClass
      extend Base
      light_translates :title
      attr_reader :title, :title_en
      def initialize(title, title_en)
        @title = title
        @title_en = title_en
      end
    end
    describe "Base" do
      it 'displays russian word' do
        model = TestClass.new('текст', 'text')
        I18n.locale = :ru
        expect(model.translated_title).to eq 'текст'
      end

      it 'displays english word' do
        model = TestClass.new('текст', 'text')
        I18n.locale = :en
        expect(model.translated_title).to eq 'text'
      end


      it 'displays russian word when english is empty' do
        model = TestClass.new('текст', '')
        I18n.locale = :en
        expect(model.translated_title).to eq 'текст'
      end

    end
  end
end
