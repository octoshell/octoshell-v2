module CloudComputing
  class TemplateKind < ApplicationRecord
    acts_as_nested_set
    has_many :conditions, as: :from, dependent: :destroy
    has_many :to_conditions, as: :to, class_name: Condition.to_s, dependent: :destroy

    has_many :templates, inverse_of: :template_kind, dependent: :destroy
    has_many :resource_kinds, inverse_of: :template_kind
    # belongs_to :template_kind, inverse_of: :resource_kinds

    # has_many :request, -> { where("#{Position.table_name}": { holder_type: Request.to_s }) },
    #                           foreign_key: 'holder_id'



    accepts_nested_attributes_for :conditions, allow_destroy: true

    translates :name, :description
    validates_translated :name, presence: true, uniqueness: { scope: :parent_id }

    validates :cloud_class, uniqueness: true, unless: :no_type?

    def self.virtual_machine_cloud_class
      find_by(cloud_class: CloudComputing::VirtualMachine.to_s)
    end

    def self.first_shared_kind
      TemplateKind.joins(:to_conditions)
              .where(cloud_computing_conditions: { from_id: virtual_machine_cloud_type
                                                            .self_and_ancestors,
                                                   from_type: TemplateKind.to_s,
                                                   max: 0 }).first

    end

    def self.cloud_classes
      [VirtualMachine]
    end


    def self.human_cloud_classes
      cloud_classes.map { |cloud_class| [cloud_class.model_name.human, cloud_class.to_s] }
    end

    # def self.human_enum_name(enum_name, enum_value)
    #   I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
    # end

    # def self.human_cloud_type(enum_value)
    #   human_enum_name(:cloud_type, enum_value)
    # end

    # def self.human_cloud_types
    #   cloud_types.keys.map do |c|
    #     [human_cloud_type(c), c]
    #   end
    # end

    # def as_json(_options = nil)
    #   {id: id, text: name }
    # end


    def no_type?
      cloud_class.present?
    end


    def human_cloud_class
      unless self.class.cloud_classes.map(&:to_s).include?(cloud_class)
        return cloud_class
      end

      eval(cloud_class).model_name.human
    end

    def child_index=(idx)
      return if new_record?

      if parent
        move_to_child_with_index(parent, idx.to_i)
      else
        move_to_root_with_index(idx.to_i)
      end
    end

    def move_to_root_with_index(index)
      roots = self.class.roots
      if roots.count == index
        move_to_right_of(roots.last)
      else
        my_position = roots.to_a.index(self)
        if my_position && my_position < index
          move_to_right_of(roots[index])
        elsif my_position && my_position == index
          # do nothing. already there.
        else
          move_to_left_of(roots[index])
        end
      end
    end

    def load_templates

      request_details = OpennebulaClient.template_list
      return requests_details unless request_details[0]

      results = []
      data = Hash.from_xml(request_details[1])['VMTEMPLATE_POOL']['VMTEMPLATE']
      data.each do |template|
        next if template['TEMPLATE']['OCTOSHELL_BOUND_TO_TEMPLATE']

        my_and_descendant_templates.where(identity: template['ID']).first_or_create! do |record|
          record.template_kind = self
          record.name = template['NAME']

          record.resources.build(value: template['TEMPLATE']['CPU'],
                                 resource_kind: ResourceKind.find_by_identity!('CPU'))
          record.resources.build(value: template['TEMPLATE']['MEMORY'].to_i / 1024,
                                 resource_kind: ResourceKind.find_by_identity!('MEMORY'))

          results << record
        end
      end

      [true, *results]

    end

    def my_and_descendant_templates
      Template.where(template_kind: self_and_descendants)
    end

    def to_s
      name
    end

    def virtual_machine?
      cloud_class == VirtualMachine.to_s
    end
  end
end
