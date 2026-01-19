require 'main_spec_helper'
module Support
  RSpec.describe Ticket do

    it 'displays possible responsibles' do
      @parent_topic = create(:topic)
      @topic = create(:topic, parent_topic: @parent_topic)
      @parent_support_user = create_support
      @support_user = create_support
      create_support
      @user = create(:user)
      @first_user_topic = @topic.user_topics.create!(user: @support_user, required: true)
      @parent_topic.user_topics.create!(user: @parent_support_user, required: true)
      @second_user_topic = @parent_topic.user_topics.create!(user: @support_user)
      @ticket = create(:ticket, topic: @topic)
      responsibles = @ticket.possible_responsibles
      expect(responsibles.detect{ |r| r.first.id == @support_user.id}).to match_array [@support_user, [@first_user_topic, @second_user_topic]]
      # Test_helper = Class.new do
      #   include Support::ApplicationHelper
      # end
      # puts @responsibles.inspect
      # puts Test_helper.new.responsible_user_topics(@ticket).inspect
    end

    it 'creates with responsible' do
      @topic = create(:topic)
      @support_user = create_support
      @user = create(:user)
      @topic.user_topics.create!(user: @support_user, required: true)
      @ticket = create(:ticket, topic: @topic)
      expect(Ticket.first.responsible).to eq @support_user
      expect(Ticket.first.subscribers).to include @support_user
    end

    it 'creates without responsible' do
      @topic = create(:topic)
      @support_user = create_support
      @user = create(:user)
      @topic.user_topics.create!(user: @support_user)
      @ticket = create(:ticket, topic: @topic)
      expect(@ticket.responsible).to eq nil
      expect(@ticket.subscribers.count).to eq 1
    end

    it 'creates with responsible' do
      @parent_topic = create(:topic)
      @topic = create(:topic, parent_topic: @parent_topic)
      @support_user = create_support
      @user = create(:user)
      @parent_topic.user_topics.create!(user: @support_user, required: true)
      @ticket = create(:ticket, topic: @topic)
      expect(@ticket.responsible).to eq @support_user
      expect(@ticket.responsible).to eq @support_user
      expect(@ticket.subscribers).to include @support_user
    end

    it 'creates without responsible' do
      @topic = create(:topic)
      @support_user = create_support
      @user = create(:user)
      @ticket = create(:ticket, topic: @topic)
      expect(@ticket.responsible).to eq nil
      expect(@ticket.subscribers.count).to eq 1
    end

    describe 'extra field' do
      before(:each) do
        @topic = create(:topic)
        @field = create(:field, topics: [@topic])
        @first_field_option = @field.field_options.create!(name_ru: 'First option',
                                                          name_en: 'First option')
        @second_field_option = @field.field_options.create!(name_ru: 'Second option',
                                                            name_en: 'Second option')
        @child_topic = build(:topic)
        @child_topic.parent_topic = @topic
        @child_topic.save!
        user = create(:user)
        @ticket = build(:ticket, topic: @child_topic, reporter: user)
        @ticket.build_field_values
        @ticket.field_values.first.value = @first_field_option.id
        @ticket.save!

        @ticket2 = build(:ticket, topic: @child_topic, reporter: user)
        @ticket2.build_field_values
        @ticket2.field_values.first.value = @second_field_option.id
        @ticket2.save!

      end

      it 'creates ticket with select fields' do
        expect(@ticket.field_values.first.value).to eq @first_field_option.id.to_s
      end

      it 'deletes extra fields' do
        expect{@second_field_option.destroy}.to change{@ticket2.field_values.count}.from(1).to(0)
      end

      it 'displays name of field' do
        expect(@ticket.field_values.first.field_option_name).to eq @first_field_option.name
      end





    end
  end
end
