module ModelTranslation
  module ActiveRecord
    module Base
      def light_translates(*args)
        args.each do |a|
          # raise "translated_#{a} method is already defined" if respond_to? "translated_#{a}"
          define_method("translated_#{a}") do
            current_locale = I18n.locale
            default_locale = I18n.default_locale
            return public_send(a) if current_locale == default_locale
            method_name = "#{a}_#{current_locale}"
            return public_send(method_name) if public_send(method_name).present?
						public_send(a)
          end
        end
      end
    end
    ::ActiveRecord::Base.extend Base
  end
end
