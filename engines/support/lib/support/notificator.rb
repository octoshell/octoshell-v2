module Support
  class Notificator < AbstractController::Base
    EMAIL = 'support_bot@octoshell.ru'.freeze

    def options
      {}
    end

    def default_options
      {
        parent_topic: { name_ru: 'Уведомления', name_en: 'Notifications' },
        topic: { name_ru: 'Уведомления', name_en: 'Notifications' },
        reporter: Support.user_class.find_by_email(EMAIL)
      }
    end

    def translate(key, options = {})
      if key.to_s.first == '.'
        path = controller_path.tr('/', '.')
        defaults = [:"#{path}#{key}"]
        defaults << options[:default] if options[:default]
        options[:default] = defaults.flatten
        key = "#{path}.#{action_name}#{key}"
      end
      I18n.translate(key, **options)
    end
    alias t translate

    def process(method = nil, *args)
      @_action_name = method
      attributes = send(method, *args)
      attributes = {} unless attributes.is_a?(Hash)
      create! attributes
    end

    def collect_assigns
      instance_variables.map { |v| [v.to_s[1..-1], instance_variable_get(v)] }
    end

    def create_bot(password)
      ActiveRecord::Base.transaction do
        bot = Support.user_class.create! email: EMAIL,
                                         password: password,
                                         activation_state: 'active'
        bot.create_profile! first_name: 'Bot', last_name: 'Botov'
      end
    end

    def name_attribute_names
      (Support::Topic.attribute_names &
                                I18n.available_locales.map { |l| "name_#{l}" })
        .map(&:to_sym)
    end

    def parent_topic(attributes)
      Support::Topic.create_with(visible_on_create: false)
                    .find_or_create_by(attributes) do |t|
                      t.name = attributes.slice(*name_attribute_names).values.first
                    end
    end

    def topic(attributes)
      Support::Topic.create_with({ visible_on_create: false }
                              .merge(attributes.except(*name_attribute_names)))
                    .find_or_create_by!(attributes.slice(*name_attribute_names)) do |t|
                      t.name = attributes.slice(*name_attribute_names).values.first
                    end
    end

    def create_field_value(attributes, ticket)
      return unless attributes

      if !attributes[:key] || !attributes[:record_id]
        raise 'You have to pass :key and :record_id argument to create field_value'
      end

      model_field = ModelField.all[attributes[:key]]
      field = Support::Field.find_or_create_by_names(model_field.names) do |f|
        f.kind = 'model_collection'
        f.model_collection = attributes[:key]
      end

      ticket.field_values.create!(topics_field: Support::TopicsField.find_or_create_by(topic: ticket.topic,
                                                                                       field: field),
                                  value: attributes[:record_id])
    end

    def create!(options)
      attributes = default_options.merge(self.options).merge options
      topic = topic(attributes[:topic]
              .merge(parent_topic: parent_topic(attributes[:parent_topic])))
      ActiveRecord::Base.transaction do
        create_field_value(
          attributes[:field_value],
          Support::Ticket.create!(attributes.except(:parent_topic, :topic,
                                                    :field_value)) do |ticket|
            ticket.message ||= render(@_action_name, Hash[collect_assigns])
            ticket.subject ||= ticket.topic.name
            ticket.topic = topic
          end
        )
      end
    end

    def engine
      eval self.class.to_s.deconstantize
    end

    def render(file, assigns = {})
      path = ActionView::LookupContext.new("#{engine.const_get('Engine').root}/app/views")
      ActionView::Base.with_empty_template_cache
                      .new(path, assigns, nil)
                      .render template: "#{engine.to_s.downcase}/notificator/#{file}"
    end

    def self.method_missing(method_name, *args)
      if action_methods.include?(method_name.to_s)
        new.process(method_name, *args)
      else
        super
      end
    end
  end
end
