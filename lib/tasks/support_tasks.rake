namespace :support do
  task :create_bot, [:pass] => :environment  do |_t, args|
    Support::Notificator.new.create_bot(args[:pass])
  end

  task october_migration: :environment do
    ActiveRecord::Base.transaction do
      Support::FieldValue.where(value: ['', nil]).destroy_all
      Support::FieldValue.all.each do |field_value|
        next unless field_value.field_id

        field = Support::Field.find(field_value.field_id)
        next unless field

        topics_field = field.topics_fields.find_by(topic: field_value.ticket.topic)
        next unless topics_field
        field_value.topics_field = topics_field
        field_value.save!
      end
    end
  end

  task required_fields: :environment do
    Support::TopicsField.all.includes(:field).each do |t_f|
      t_f.required = t_f.field.required
      t_f.save!
    end
  end



  task convert_fields: :environment do
    ActiveRecord::Base.transaction do
      table = Roo::Spreadsheet.open('fields.xlsx')
      rows = table.sheet(0).to_a
        rows[1..-1].each do |row|
          field_id = row[0]
          type = row[5]
          # options = row[6]&.split('.')
          field = Support::Field.find(field_id)
          if %w[text markdown].include? type
            field.kind = type
          elsif %w[model_collection(cluster) radio check_box].include? type
            attrs = %w[name_ru name_en hint_ru hint_en
                       required contains_source_code url search]
            new_field = Support::Field.new field.attributes.slice(*attrs)
            if type == 'model_collection(cluster)'
              new_field.kind = 'model_collection'
              new_field.model_collection = 'cluster'
            elsif type == 'radio'
              new_field.kind = type
              new_field.field_options.new(name_ru: 'Да', name_en: 'Yes')
              new_field.field_options.new(name_ru: 'Нет', name_en: 'No')
            else
              new_field.kind = type
              new_field.field_options.new(name_ru: 'Да', name_en: 'Yes')
            end
            new_field.save!
            field.name_ru += ' (старое)'
            field.name_en += ' (old)'
            field.topics_fields.each do |t_f|
              attributes = t_f.attributes.slice('topic_id', 'required')
              new_field.topics_fields.create!(attributes)
              t_f.topic_id = nil
              t_f.save!
            end
          else
            raise 'unknown type of field'
          end
          field.save!
        end
        Support::Field.where(kind: nil).each do |field|
          field.kind = 'text'
          field.save!
        end
        # raise 'mistake'
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
