module ModelTranslation
  class Attributes < Module
    def initialize(*attributes)
      @attributes = attributes.map(&:to_sym)
      # puts @attributes
      # puts @attributes
      attributes.each do |attribute|
        redefine_default_reader(attribute)
        define_writer(attribute)
      end
    end

    def included(base)
      puts base.to_s.inspect
      @attributes.each do |attribute|
        default_method_name = "#{attribute}_#{I18n.default_locale}"
        # base.send :alias_method, default_method_name, attribute
        # puts base.instance_methods.inspect

        # base.send :remove_method, attribute
        # base.class_eval do
        #   redefine_default_reader(attribute)
        #   define_writer(attribute)
        # end

        # base.send :remove_method, attribute
      end

    end

    def redefine_default_reader(attribute)
      puts "!!!!!!!!!!!!!!"
      default_method_name = "#{attribute}_#{I18n.default_locale}"
      define_method(attribute) do
        current_locale = I18n.locale
        puts current_locale
        puts current_locale
        puts "!!!!!!!!!!!!!!"
        method_name = "#{attribute}_#{current_locale}"
        public_send(method_name) || public_send(default_method_name)
      end
    end

    def define_writer(attribute)
      define_method("#{attribute}_#{I18n.default_locale}=") do |arg|
        send("#{attribute}=", arg)
      end
    end
  end
end
