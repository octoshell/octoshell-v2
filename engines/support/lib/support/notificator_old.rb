module Support
  class Notificator < AbstractController::Base

    def self.topic_names
      I18n.available_locales.map { |l| :"topic_#{l}" }.freeze
    end

    def self.parent_topic_names
      topic_names.map { |l| :"parent_#{l}" }.freeze
    end
    TICKET_ATTRS = %i[subject message attachment reporter responsible].freeze
    TOPIC_ATTRS = %i[visible_on_create].freeze

    def self.email
      'support_bot@octoshell.ru'.freeze
    end

    def parent_topic_ru
      'Уведомления'
    end

    def parent_topic_en
      'Notifications'
    end

    def topic_ru
      parent_topic_ru
    end

    def topic_en
      parent_topic_en
    end


    def translate(key, options = {})
      if key.to_s.first == "."
        path = controller_path.tr("/", ".")
        defaults = [:"#{path}#{key}"]
        defaults << options[:default] if options[:default]
        options[:default] = defaults.flatten
        key = "#{path}.#{action_name}#{key}"
      end
      I18n.translate(key, options)
    end
    alias :t :translate

    def process(method = nil, *args)
      @_action_name = method
      attributes = send(method, *args)
      attributes = {} unless attributes.is_a?(Hash)
      create! attributes
    end

    def collect_assigns
      instance_variables.map{ |v| [v.to_s[1..-1], instance_variable_get(v)] }
    end

    def create_bot(password)
      ActiveRecord::Base.transaction do
        bot = Support.user_class.create! email: self.class.email,
                                         password: password,
                                         activation_state: 'active'
        bot.create_profile! first_name: 'Bot', last_name: 'Botov'
      end
    end

    def bot
      @bot ||= Support.user_class.find_by_email!(self.class.email)
    end

    def process_ticket_attributes(attributes)
      unless attributes[:message]
        message = render(@_action_name, Hash[collect_assigns])
        attributes[:message] = message
      end
      attributes[:reporter] ||= bot
      attributes[:subject] ||= attributes[:topic].name
    end


    def form_topic_attributes(attrs, attributes)
      topic_names = {}
      attrs.each do |a|
        lang = a.to_s.split('_').last
        topic_names[:"name_#{lang}"] = attributes.delete(a)
      end
      topic_names
    end

    def parent_topic(attributes)
      p_a = form_topic_attributes(self.class.parent_topic_names, attributes)
      Support::Topic.find_or_create_by_names(p_a) do |topic|
        topic.visible_on_create = false
      end
    end

    def process_topic_attributes(attributes)
      t_a = form_topic_attributes(self.class.topic_names, attributes)
      parent_topic = parent_topic(attributes)
      attributes[:topic] = Support::Topic.find_or_create_by_names(t_a) do |topic|
        topic.visible_on_create = attributes[:visible_on_create]
        topic.parent_topic = parent_topic
      end
    end

    def process_field_value_attributes(attributes)
      f_v = attributes.delete(:field_value)
      return unless f_v

      if !f_v[:key] || !f_v[:record_id]
        raise 'You have to pass :key and :record_id argument to create field_value'
      end

      model_field = ModelField.all[f_v[:key]]
      # ticket = Support::Ticket.new(args.except(:topic, :key, :record_id))
      field = Support::Field.find_or_create_by_names(model_field.names) do |f|
        f.kind = 'model_collection'
        f.model_collection =  f_v[:key]
      end

      topic = attributes[:topic]

      t_f = Support::TopicsField.find_or_create_by(topic: topic, field: field)
      { topics_field: t_f, value: f_v[:record_id] }
    end

    def create!(arg)
      attributes = arg.dup
      puts attributes.inspect.red
      (TICKET_ATTRS + self.class.topic_names + self.class.parent_topic_names +
       TOPIC_ATTRS + [:field_value]).each do |a|
        attributes[a] ||= try a
      end
      puts attributes.inspect.red
      process_topic_attributes(attributes)
      puts attributes.inspect.red
      process_ticket_attributes(attributes)
      f_v_attrs = process_field_value_attributes(attributes)
      attributes.compact!
      ActiveRecord::Base.transaction do
        ticket = Support::Ticket.create! attributes
        ticket.field_values.create!(f_v_attrs) if f_v_attrs.is_a?(Hash)
      end
    end

    def engine
      eval self.class.to_s.deconstantize
    end

    def render(file, assigns = {})
      path = "#{engine.const_get("Engine").root}/app/views"
      ActionView::Base.new(path, assigns).render file: "#{engine.to_s.downcase}/notificator/#{file}"
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
