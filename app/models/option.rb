# == Schema Information
#
# Table name: options
#
#  id                  :integer          not null, primary key
#  owner_type          :string
#  owner_id            :integer
#  name_ru             :string
#  name_en             :string
#  value_ru            :text
#  value_en            :text
#  category_value_id   :integer
#  options_category_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  admin               :boolean          default("false")
#

class Option < ApplicationRecord
  belongs_to :owner, inverse_of: :options, polymorphic: true
  belongs_to :category_value, inverse_of: :options
  belongs_to :options_category, inverse_of: :strict_options

  translates :name, :value
  validates :owner, presence: true
  validates_translated :name, presence: true, unless: proc { |opt| opt.name_with_category?}
  validates_translated :value, presence: true, unless: proc { |opt| opt.value_with_category?}
  validates :options_category, presence: true, if: proc { |opt| opt.name_with_category?}
  validates :category_value, presence: true, if: proc { |opt| opt.value_with_category?}
  validates_uniqueness_of :name_ru, scope: %i[owner_id owner_type], if: proc { |option| option.name_ru.present? }
  validates_uniqueness_of :name_en, scope: %i[owner_id owner_type], if: proc { |option| option.name_en.present? }
  validates_uniqueness_of :options_category_id, scope: %i[owner_id owner_type], if: proc { |option| option.name_with_category? }
  validates_uniqueness_of :category_value_id, scope: %i[owner_id owner_type], if: proc { |option| option.value_with_category? }


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
    value || (category_value ? category_value.value : nil)
  end

  def readable_name
    name || (options_category ? options_category.name : nil)
  end

end
