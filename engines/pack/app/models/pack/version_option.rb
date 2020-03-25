# == Schema Information
#
# Table name: pack_version_options
#
#  id                  :integer          not null, primary key
#  name_en             :string
#  name_ru             :string
#  value_en            :string
#  value_ru            :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  category_value_id   :integer
#  options_category_id :integer
#  version_id          :integer
#
# Indexes
#
#  index_pack_version_options_on_version_id  (version_id)
#

module Pack
  class VersionOption < ApplicationRecord
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
    attr_writer :name_type, :value_type


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
