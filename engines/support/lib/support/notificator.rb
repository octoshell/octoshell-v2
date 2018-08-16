module Support
  class Notificator < AbstractController::Base
    # include AbstractController::Translation
    #TODO TOPIC в локаль

    def topic_name
      'Уведомления'.freeze
    end

    def self.email
      'support_bot@octoshell.ru'.freeze
    end

    def translate(key, options = {})
      if key.to_s.first == "."
        path = controller_path.tr("/", ".")
        defaults = [:"#{path}#{key}"]
        defaults << options[:default] if options[:default]
        options[:default] = defaults.flatten
        key = "#{path}.#{action_name}#{key}".gsub(/notificator/, 'notificators')
      end
      I18n.translate(key, options)
    end
    alias :t :translate

    def process(method = nil, *args)
      @_action_name = method
      attributes = send(method, *args)
      unless attributes[:message]
        message = render(method, Hash[collect_assigns])
        attributes[:message] = message
      end
      create! attributes
    end

    def collect_assigns
      instance_variables.map{ |v| [v.to_s[1..-1], instance_variable_get(v)] }
    end

    def create_bot(password)
      ActiveRecord::Base.transaction do
        bot = Support.user_class.create! email: self.class.email,
                                         password: password
        bot.create_profile! first_name: 'Bot', last_name: 'Botov'
      end
    end

    def bot
      @bot ||= Support.user_class.find_by_email!(self.class.email)
    end

    def topic(name = topic_name)
      @topic ||= Topic.find_or_create_by!(name_ru: name)
    end

    def create!(arg)
      attributes = arg.dup
      attributes.reverse_merge! topic: topic,
                                reporter: bot,
                                subject: topic.name
      Support::Ticket.create! attributes
    end

    def engine
      eval self.class.to_s.deconstantize
    end

    def render(file, assigns = {})
      path = "#{engine.const_get("Engine").root}/app/views"
      ActionView::Base.new(path, assigns).render file: "#{engine.to_s.downcase}/notificators/#{file}"
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
