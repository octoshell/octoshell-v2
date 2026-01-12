class ApplicationRecord < ActiveRecord::Base
  extend ModelTranslation::ActiveRecord
  def self.inherited(subclass)
    subclass.has_paper_trail versions: { name: :paper_trail_versions },
                             version: :paper_trail_version,
                             if: proc { |i| i.class.versions_enabled }
    super
  end

  def self.versions_enabled
    true
  end

  self.abstract_class = true

  def self.interface(&block)
    instance_interface = Module.new(&block)
    include(instance_interface)
  end

  def self.extend_with_options
    has_many :options, as: :owner
    accepts_nested_attributes_for :options, allow_destroy: true
  end

  def self.order_by_name
    locale_name = [current_locale_column(:name)]
    other_names = locale_columns(:name) - locale_name
    name_array = locale_name + other_names
    order(*name_array)
  end

  def self.for_link(link)
    return self unless eval(to_s.split('::').first).link?(link)

    yield(self)
  end

  def self.ransackable_attributes(_auth_object = nil)
    column_names + _ransackers.keys
  end

  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s } + _ransackers.keys
  end

  def self.find_or_create_by_names(names)
    record = nil
    names.keys.each do |name|
      record ||= find_by("#{name}": names[name])
    end

    return record if record

    record = new(names)
    main_name = "name_#{I18n.locale}"
    record.public_send("#{main_name}=", names.values.compact.first) unless record.public_send(main_name)
    yield(record) if block_given?
    record.save!
    record
  end

  def self.old_enum(arg)
    values = arg.values.first
    key = arg.keys.first
    case values
    when Hash
      enum arg
    when Array
      enum(key, values.each_with_index.map { |x, i| [x, i] }.to_h)
    end
  end

  scope :id_finder, (lambda do |id|
    where('CAST(id AS varchar) LIKE ?', "%#{id}%")
  end)
end
