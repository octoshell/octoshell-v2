require 'initial_create_helper'
module Support
  describe Notificator do
    it 'creates bot once' do
      expect { Notificator.new.create_bot 'strong_password' }.to change { Support.user_class.count }.by(1)
      expect(Support.user_class.find_by_email!('support_bot@octoshell.ru').profile
                    .first_name).to eq 'Bot'
    end

    describe 'create_methods' do
      before(:each) do
        Notificator.new.create_bot 'strong_password'
        class ::Support::Notificator
          def test_index(lang)
            @language = lang
            {}
          end
        end
      end

      it 'creates topic once' do
        expect { Notificator.new.topic }.to change { Support::Topic.count }.by(1)
        expect { Notificator.new.topic }.to change { Support::Topic.count }.by(0)
      end

      it 'creates ticket' do
        expect { Notificator.new.create!(message: 'aloha') }.to change { Support::Ticket.count }.by(1)
      end

      it 'renders' do
        expect(Notificator.new.render('test_index', language: 'markdown_uniq')).to include 'markdown_uniq'
      end


      it 'test_index' do
        expect(Notificator.test_index('markdown_uniq').message).to include 'markdown_uniq'
      end

      it '::test_m in sub_class' do
        module Notengine
          class TestNotificator < Notificator
            def test_m(lang)
              @language = lang
            end
          end
        end
        expect(Notengine::TestNotificator.new.engine).to eq Notengine
      end
    end
  end
end
