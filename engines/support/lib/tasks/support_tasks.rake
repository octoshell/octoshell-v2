namespace :support do
  task :create_bot, [:pass] => :environment  do |_t, args|
    Support::Notificator.new.create_bot(args[:pass])
  end

  task october_migration: :environment do
    ActiveRecord::Base.transaction do
      Support::FieldValue.all.each do |field_value|
        field = Support::Field.find(field_value.field_id)
        next unless field

        topics_field = field.topics_fields.find_by!(topic: field_value.ticket.topic)
        field_value.topics_field = topics_field
        field_value.save!
      end
    end
  end

  task fix_topics: :environment do

    def merge(source, to)
      return if source == to

      raise 'merge error' if source.subtopics.any?

      Support::Ticket.where(topic: source).update_all(topic_id: to.id)
      source.destroy!
    end

    ActiveRecord::Base.transaction do
      parent_topic = Support::Notificator.new.parent_topic
      core_topic = Core::Notificator.new.topic
      pack_topic = Pack::Notificator.new.topic

      Support::Topic.where(name_ru: core_topic.name_ru).each do |t|
        merge(t, core_topic)
      end

      Support::Topic.where(name_ru: pack_topic.name_ru).each do |t|
        merge(t, pack_topic)
      end

      Support::Topic.where(name_ru: 'Заявка на доступ к версиям пакетов').each do |t|
        merge(t, Pack.support_access_topic)
      end

      Support::Topic.where(name_ru: parent_topic.name_ru).each do |t|
        merge(t, parent_topic)
      end

      parent_topic.update!(visible_on_create: false)
    end
  end
end
