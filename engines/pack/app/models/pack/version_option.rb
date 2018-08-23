module Pack
  class VersionOption < ActiveRecord::Base
    belongs_to :version, inverse_of: :version_options
    belongs_to :category_value, inverse_of: :version_options
    belongs_to :options_category, inverse_of: :strict_version_options

    translates :name, :value
    validates :version, presence: true
    validates_translated :name, presence: true, unless: proc { |opt| opt.name_with_category?}
    validates_translated :value, presence: true, unless: proc { |opt| opt.value_with_category?}
    validates :options_category, presence: true, if: proc { |opt| opt.name_with_category?}
    validates :category_value, presence: true, if: proc { |opt| opt.value_with_category?}
    validates_uniqueness_of :name_ru, scope: :version_id, if: proc { |option| option.name_ru.present? }
    validates_uniqueness_of :name_en, scope: :version_id, if: proc { |option| option.name_en.present? }
    attr_accessor :stale_edit
    attr_writer :name_type, :value_type
    validate :stale_check


    before_validation do
      category_value &&
        options_category != category_value.options_category &&
        errors.add(:category_value, :invalid)
      if name_with_category?
        self.name_ru = self.name_en = nil
      else
        self.options_category = nil
      end
      if value_with_category?
        self.value_ru = self.value_en = nil
      else
        self.category_value = nil
      end
    end

    validate do
      if value_type == 'with_category' && name_type != 'with_category'
        errors.add(:value_type, :invalid)
      end
    end

    def stale_check
      return unless stale_edit
      mark_for_destruction
      errors.add(:deleted_record, I18n.t("stale_error_nested"))
    end


    def content_types
      %w[with_category without_category]
    end

    def name_type
      @name_type ||= options_category ? 'with_category' : 'without_category'
    end

    def value_type
      @value_type ||= category_value ? 'with_category' : 'without_category'
    end

    def name_with_category?
      puts name_type
      name_type == 'with_category'
    end

    def value_with_category?
      value_type == 'with_category'
    end

    def readable_value
      value || category_value.value
    end

    def readable_name
      name || options_category.category
    end

  end
end
