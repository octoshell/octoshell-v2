module ModelTranslation
  module ActiveRecord
    def validates_translated(*attributes)
      options = attributes.extract_options!
      attributes.each do |attribute|
        I18n.available_locales.map { |l| "#{attribute}_#{l}" }.each do |locale_column|
          if_proc = options[:if] || proc { true }
          new_options = options.dup
          new_options[:if] = proc do |m|
            I18n.locale.to_s == locale_column.to_s.split('_').last &&
              if_proc.call(m)
          end
					validates *[locale_column, new_options]
        end
      end
    end

    def translates(*attributes)
      options = attributes.extract_options!
      options[:fallback] ||= :any
      super(*attributes, options)
    end
  end
end
