require 'main_spec_helper'
module Support
  class TestNotificator < Notificator

    def options
      {
        topic: { name_en: 'NOT USED because overriden in method' },
        field_value: { key: :pack_access, record_id: Pack::Access.last.id },
        subject: 'Subject in method',
        reporter: User.last
      }
    end

    def _test_with_template(name)
      @name = name
      { topic: { name_en: 'Greetings' } }
    end

  end

  describe TestNotificator do
    it 'creates ticket' do
      Support::Notificator.new.create_bot 'strong_password'
      user = create(:user)
      access = create(:access, created_by: user, who: user)
      TestNotificator._test_with_template('The best user')
      expect(FieldValue.last).to have_attributes(value: access.id.to_s)
      expect(Ticket.last.topic).to have_attributes(name_en: 'Greetings', name_ru: 'Greetings')
      expect(Ticket.last).to have_attributes(subject: 'Subject in method', reporter: user)

    end

  end
  describe Notificator do
    # it 'creates a topic' do
    #   expect do
    #     Interface.send(:find_or_create_topic_by_names, name_ru: 'Новая тема',
    #                                           name_en: 'New topic')
    #
    #   end.to change { Topic.count }.by(1)
    #   expect(Topic.last).to have_attributes(name_ru: 'Новая тема',
    #                                         name_en: 'New topic')
    # end
    #
    # it 'creates a topic without main language name' do
    #   arr = (I18n.available_locales - [I18n.locale]).map { |l| ["name_#{l}", l] }
    #   hash = Hash[arr]
    #   expect do
    #     Interface.send(:find_or_create_topic_by_names, hash)
    #
    #   end.to change { Topic.count }.by(1)
    # end
    #
    # it 'does not create a topic' do
    #   args = Hash[I18n.available_locales.map do |locale|
    #     [:"name_#{locale}", "name_#{locale}"]
    #   end]
    #   Topic.create!("name_#{I18n.locale}" => "name_#{I18n.locale}")
    #
    #   expect do
    #     Interface.send(:find_or_create_topic_by_names, args)
    #
    #   end.to change { Topic.count }.by(0)
    # end

    it 'creates ticket' do
      Support::Notificator.new.create_bot 'strong_password'
      user = create(:user)
      access = create(:access, created_by: user)
      Notificator.new.create!(subject: 'subject', reporter: user,
                              message: 'Interface really works!!!!',
                              topic: { name_en: 'test' },
                              field_value: { key: :pack_access,
                                             record_id: access.id })

      expect(FieldValue.last).to have_attributes(value: access.id.to_s)
      expect(FieldValue.last.ticket.topic.name_en).to eq 'test'
      expect(Ticket.last).to have_attributes(subject: 'subject', reporter: user,
                                            message: 'Interface really works!!!!')

    end


  end
end
