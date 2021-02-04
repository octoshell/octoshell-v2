module CloudComputing
  module SupportMethods
    def self.seed
      create_virtual_machine
      create_disk
    end

    def self.dev_seed
      seed
      project = Core::Project.first
      access = CloudComputing::Access.create!(for: project,
                                              user: project.owner,
                                              allowed_by: User.superadmins.first)
      template = CloudComputing::TemplateKind.virtual_machine.first.items.first

      CloudComputing::SupportMethods.add_positions(access, template)

    end


    def self.create_virtual_machine
      nebula_id = 71
      virtual_kind = CloudComputing::TemplateKind.create!(name_ru: 'Виртуальная машина',
                                                      name_en: 'Virtual machine',
                                                      cloud_type: 'virtual_machine')

      memory = virtual_kind.resource_kinds.create!(name_ru: 'Оперативная память',
        name_en: 'Main Memory', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'MEMORY', content_type: 'decimal')

      cpu = virtual_kind.resource_kinds.create!(name_ru: 'Центральные процессоры',
        name_en: 'CPU', measurement_en: '', measurement_ru: '',
        identity: 'CPU', content_type: 'decimal',
        help_ru: 'Число процессоров: 0,5 - половина процессора, 2,0 - 2 процессора')


      hard = virtual_kind.resource_kinds.create!(name_ru: 'Жёсткий диск',
        name_en: 'Hard drive', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'DISK=>SIZE', content_type: 'positive_integer')

      not_editable = virtual_kind.resource_kinds.create!(name: 'not_editable',
        measurement: 'm', content_type: 'positive_integer')


      virtual_kind.items.create!(name: 'First virtual machine',
                                 description_en: 'Description', new_requests: true,
                                 identity: nebula_id, description_ru: 'Описание'
                                 ) do |item|
        item.resources.new(resource_kind: memory, min: 1, max: 2,
                           value: 1.5, editable: true)
        item.resources.new(resource_kind: cpu, min: 0.5, max: 2.5, value: 1,
                           editable: true)
        item.resources.new(resource_kind: hard, min: 1, max: 200, value: 2,
                           editable: true)
        item.resources.new(resource_kind: not_editable, value: 1000)
      end
    end

    def self.create_disk

      disk_kind = CloudComputing::TemplateKind.create!(name_ru: 'Диск',
                                                      name_en: 'Disk',
                                                      cloud_type: 'disk')

      hard = disk_kind.resource_kinds.create!(name_ru: 'Жёсткий диск',
        name_en: 'Hard drive', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'SIZE', content_type: 'positive_integer')

      not_editable = disk_kind.resource_kinds.create!(name: 'not_editable',
        measurement: 'm', content_type: 'positive_integer')


      disk_kind.items.create!(name: 'Disk',
                                 description_en: 'Disk', new_requests: true,
                                 description_ru: 'Disk'
                                 ) do |item|
        item.resources.new(resource_kind: hard, min: 100, max: 500, value: 200,
                           editable: true)
        item.resources.new(resource_kind: not_editable, value: 1000)
      end
    end

    def self.add_positions(holder, template)

      holder.positions.create!(amount: 2, item: template)
      holder.positions.create!(amount: 1, item: template)
      template.resources.where(editable: true).each do |resource|
        holder.positions.first.resource_items.create!(resource: resource,
                                                          value: resource.value)
        value = if resource.resource_kind.positive_integer?
                  resource.value.to_i + 1
                else
                  resource.value.to_f + 1
                end
        holder.positions.second.resource_items.create!(resource: resource,
                                                             value: value)
      end
    end
  end
end
