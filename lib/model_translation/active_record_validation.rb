module ModelTranslation
  module ActiveRecordValidation
    def validates_translated(*attributes)
      options = attributes.extract_options!
      raise "If block is unsupported" if options[:if]
      attributes.each do |attribute|
        locale_columns(attribute).each do |locale_column|
          options[:if] = proc { I18n.locale.to_s == locale_column.to_s.split('_').last }
					validates *[locale_column, options]
        end
      end
    end
  end
  ::ActiveRecord::Base.extend ActiveRecordValidation
end
