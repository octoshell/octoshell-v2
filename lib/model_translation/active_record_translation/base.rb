
module ModelTranslation
  module ActiveRecord
    module Base

      def light_translates(*columns)
        available_locales = I18n.available_locales
        columns.each do |column|
          define_method("translated_#{column}") do
            current_locale = I18n.locale
            method_name = "#{column}_#{current_locale}"
            return public_send(method_name) if public_send(method_name).present?
            public_send(column)
          end
          define_method("#{column}_#{I18n.default_locale}") do
            send(column)
          end

          define_method("#{column}_#{I18n.default_locale}=") do |arg|
            send("#{column}=", arg)
          end

        end

        define_singleton_method :human_attribute_name do |name, options = {}|
          default, _unused, locale = *name.to_s.rpartition('_')
          unless columns.include?(default.to_sym) &&
                 available_locales.include?(locale.to_sym)
            return super(name, options)
          end
          s = super name, options.merge(default: '')
          return s if s.present?
          default_translate = super(default, options)
          lang_suffix = I18n.t("model_translation.#{locale}")
          "#{default_translate} (#{lang_suffix})"
        end

        define_singleton_method :locale_columns do |column|
          if columns.exclude? column
            raise "The #{column} column is not passed to light_translates call"
          end
          available_locales.map do |locale|
            "#{column}_#{locale}".to_sym
          end
        end
      end
    end
    # ::ActiveRecord::Base.extend Base
  end
end
