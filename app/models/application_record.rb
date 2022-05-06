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

  def self.find_or_create_by_names(names)
    record = nil
    names.keys.each do |name|
      record ||= find_by("#{name}": names[name])
    end

    return record if record

    record = new(names)
    main_name = "name_#{I18n.locale}"
    unless record.public_send(main_name)
      record.public_send("#{main_name}=", names.values.compact.first)
    end
    yield(record) if block_given?
    record.save!
    record
  end

end
