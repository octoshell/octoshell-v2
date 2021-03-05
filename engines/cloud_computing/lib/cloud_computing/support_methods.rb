module CloudComputing
  module SupportMethods
    def self.seed
      create_virtual_machine
      # create_disk
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


    def self.create_virtual_machine(nebula_id = 71)
      virtual_kind = CloudComputing::TemplateKind.create!(name_ru: 'Виртуальная машина',
                                                      name_en: 'Virtual machine',
                                                      cloud_class: VirtualMachine)

      memory = virtual_kind.resource_kinds.create!(name_ru: 'Оперативная память',
        name_en: 'Main Memory', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'MEMORY', content_type: 'decimal')

      cpu = virtual_kind.resource_kinds.create!(name_ru: 'Центральные процессоры',
        name_en: 'CPU', measurement_en: '', measurement_ru: '',
        identity: 'CPU', content_type: 'positive_integer')


      hard = virtual_kind.resource_kinds.create!(name_ru: 'Жёсткий диск',
        name_en: 'Hard drive', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'DISK=>SIZE', content_type: 'positive_integer')

      not_editable = virtual_kind.resource_kinds.create!(name: 'not_editable',
        measurement: 'm', content_type: 'positive_integer')


      virtual_kind.templates.create!(name: 'First virtual machine',
                                 description_en: 'Description', new_requests: true,
                                 identity: nebula_id, description_ru: 'Описание'
                                 ) do |template|
        template.resources.new(resource_kind: memory, min: 1, max: 2,
                           value: 1.5, editable: true)
        template.resources.new(resource_kind: cpu, min: 0.5, max: 2.5, value: 1,
                           editable: true)
        template.resources.new(resource_kind: hard, min: 1, max: 200, value: 2,
                           editable: true)
        template.resources.new(resource_kind: not_editable, value: 1000)
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

    def self.create_vm_with_identities(holder, template, hash)
      item = holder.items.create!(template: template)
      VirtualMachine.create!(item: item)
      hash.each do |key, value|
        resource = template.resources.joins(:resource_kind)
                           .where(cloud_computing_resource_kinds:{
                             identity: key
          }).first
        item.resource_items.create!(resource: resource, value: value.to_s)
      end

    end

    def self.add_positions(holder, template)

      item = holder.items.create!(template: template)
      VirtualMachine.create!(item: item)
      template.resources.where(editable: true).each do |resource|
        # holder.virtual_machine.resource_items.create!(resource: resource,
        #                                               value: resource.value)
        value = if resource.resource_kind.positive_integer?
                  resource.value.to_i + 1
                elsif resource.resource_kind.decimal?
                  resource.value.to_f + 1
                else
                  '1'
                end
        item.resource_items.create!(resource: resource,
                                                      value: value)
      end
    end

    def self.example_vm_hash
      {"ID"=>"518",
       "UID"=>"0",
       "GID"=>"0",
       "UNAME"=>"oneadmin",
       "GNAME"=>"oneadmin",
       "NAME"=>"octo-8-42-31",
       "PERMISSIONS"=>
        {"OWNER_U"=>"1",
         "OWNER_M"=>"1",
         "OWNER_A"=>"0",
         "GROUP_U"=>"0",
         "GROUP_M"=>"0",
         "GROUP_A"=>"0",
         "OTHER_U"=>"0",
         "OTHER_M"=>"0",
         "OTHER_A"=>"0"},
       "LAST_POLL"=>"1614530375",
       "STATE"=>"3",
       "LCM_STATE"=>"3",
       "PREV_STATE"=>"3",
       "PREV_LCM_STATE"=>"3",
       "RESCHED"=>"0",
       "STIME"=>"1614117962",
       "ETIME"=>"0",
       "DEPLOY_ID"=>"629466fe-4aa6-4bd2-b17e-0ad5057342aa",
       "MONITORING"=>
        {"CPU"=>"3.0",
         "DISKRDBYTES"=>"39167872",
         "DISKRDIOPS"=>"1229",
         "DISKWRBYTES"=>"2486272",
         "DISKWRIOPS"=>"1733",
         "DISK_SIZE"=>[{"ID"=>"0", "SIZE"=>"160"}, {"ID"=>"1", "SIZE"=>"1"}],
         "ID"=>"518",
         "MEMORY"=>"219164",
         "NETRX"=>"83924315",
         "NETTX"=>"12302",
         "TIMESTAMP"=>"1614530375"},
       "TEMPLATE"=>
        {"AUTOMATIC_DS_REQUIREMENTS"=>"(\"CLUSTERS/ID\" @> 0)",
         "AUTOMATIC_NIC_REQUIREMENTS"=>"(\"CLUSTERS/ID\" @> 0)",
         "AUTOMATIC_REQUIREMENTS"=>
          "(CLUSTER_ID = 0) & !(PUBLIC_CLOUD = YES) & !(PIN_POLICY = PINNED)",
         "CLONING_TEMPLATE_ID"=>"71",
         "CONTEXT"=>
          {"DISK_ID"=>"1",
           "ETH0_CONTEXT_FORCE_IPV4"=>"",
           "ETH0_DNS"=>"172.16.2.11",
           "ETH0_EXTERNAL"=>"",
           "ETH0_GATEWAY"=>"172.16.2.11",
           "ETH0_GATEWAY6"=>"",
           "ETH0_IP"=>"172.16.2.7",
           "ETH0_IP6"=>"",
           "ETH0_IP6_PREFIX_LENGTH"=>"",
           "ETH0_IP6_ULA"=>"",
           "ETH0_MAC"=>"02:00:ac:10:02:07",
           "ETH0_MASK"=>"",
           "ETH0_METRIC"=>"",
           "ETH0_METRIC6"=>"",
           "ETH0_MTU"=>"1500",
           "ETH0_NETWORK"=>"",
           "ETH0_SEARCH_DOMAIN"=>"",
           "ETH0_VLAN_ID"=>"",
           "ETH0_VROUTER_IP"=>"",
           "ETH0_VROUTER_IP6"=>"",
           "ETH0_VROUTER_MANAGEMENT"=>"",
           "ETH1_CONTEXT_FORCE_IPV4"=>"",
           "ETH1_DNS"=>"10.0.0.1",
           "ETH1_EXTERNAL"=>"",
           "ETH1_GATEWAY"=>"77.88.8.88",
           "ETH1_GATEWAY6"=>"",
           "ETH1_IP"=>"10.0.0.3",
           "ETH1_IP6"=>"",
           "ETH1_IP6_PREFIX_LENGTH"=>"",
           "ETH1_IP6_ULA"=>"",
           "ETH1_MAC"=>"02:00:0a:00:00:03",
           "ETH1_MASK"=>"",
           "ETH1_METRIC"=>"",
           "ETH1_METRIC6"=>"",
           "ETH1_MTU"=>"",
           "ETH1_NETWORK"=>"",
           "ETH1_SEARCH_DOMAIN"=>"",
           "ETH1_VLAN_ID"=>"3203",
           "ETH1_VROUTER_IP"=>"",
           "ETH1_VROUTER_IP6"=>"",
           "ETH1_VROUTER_MANAGEMENT"=>"",
           "NETWORK"=>"YES",
           "OCTOSHELL_TEMPLATE"=>"OCTOSHELL_TEMPLATE",
           "SSH_PUBLIC_KEY"=>
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJwZNWvADjgvkKqr0Qz6CUf1I+hZbKvYMAXoPhWlG0oRIbvAevviTtqBsPLw0NFVY6KghHtnsNIfBPxMDTn1U/abs1Asv3JWfD7oA2hbY3/jdQZWeNdhSRGjfxCZOPDgn4QvJ8PPzg/r45cpwGtl2OD97qqNvMUUjkPqPBL4SrFFRYUE3/qnUEc5olddcPk5ApcpjKbza7bv4sHVa7kHg/3HMFKb7Qr22wbjPHNmjdlaRSLuyVaivvjW6pAsX4hInWIzG/bqj21VEIQWqSTXl1thgdt1Sph6EYUzQFL1Ir8JIvXaN9aVdkqCwVVAIqURC1b0xx0lXsCJeqMdtv+RfD andrey@andrey-Vostro-3558\n" +
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+81/wHCm3oZWPYtGjCLtkn7OcCVVgJUUtCG/L1fy9zM3i6rEVEy9HJXS6vL01jV4bVu0tawB4DbzfNiYneVVVSA7rfYjcKYEWvLUg//arWV+LLrn37qBt93yJmzRJR131fgn1mvR/uTpYVUjH18nrVXTUarj5lVcAm7ga13uXgNFnIM7NHvTJ5jOpikMk6tnp7E/xvFX7QTRaZqzncC8ynrw5W+smPFRQQDFnfFQU99R/HFoSL0VDxcqhLRGZ3aH+ITD7PzjyGj3aYxLSgPYueOdUJXmKX53r0hUdWLyNLaIzIiVynejBx+e1kyon/cPCIzW/vd1LIJAN13jde0S1 user2@octoshell.ru\n" +
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgmKEf8XWRTYsFRl+hOqj8arOu9COhPjnJYS17JRBbMLg4tWyeuJhr1tlyXX3T3MMD1LbYdVrlNvnhA0J2oxAU6EHJrIs5LqWZPezTBqoARyFAADkKafVdyJard/jsfwQdwWF165uUWstQbb+iWVH8J5PSkxETbcduKaw+tcBLb2xZBmeA/YDUyM6KwcFUWWNChw0HM9d2XtqunraPpiV6YVhZfom0BP1bCxQJcD+yG8gQ3o4L9gLTUxBAuCA5Md10by/QD/yJ0z/bJdkjpf8fIv3+6Pru4ymWAcqVknQBhn5HdWB7HRdZWclfQfGDQwQhxtNYUHv0yLpSD3tQcmh9 andrey@andrey-Vostro-3558\n" +
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC78i5kmfA0uhceDn23OHO7ci4JW9l+eh7C0t/JTqc3lsxW17fkfkYanS/nz2LXWaZLhwnK7MDx8fm8qiV0opSwAZGZxOKaq4Ht++3hQAylYiefpXHTy8Cdc+TZbcgjKCI3hTmO1lG6NA7uu15OCq2m9kCc64dEPKqr1rZ7mZ9Eis9yGLlOtWdOupR+N6lwNrtjVcvgqoGoGgf/RHoNzFRGXAFXU/jc1YlBq4f9SWBN7ZynU0qsDNXX7qNvNq473MTV64NNBHcjIPkZS1gaQScbpa1qQOyXRagP7Cku7kPc0s7a6ZvAv0S5h1CuIY8K3t6rb/UHRQEhbiP6M2Unx6l9 user1@octoshell.ru",
           "TARGET"=>"hda",
           "USER"=>"root"},
         "CPU"=>"1.5",
         "DISK"=>
          {"ALLOW_ORPHANS"=>"NO",
           "CLONE"=>"NO",
           "CLONE_TARGET"=>"SYSTEM",
           "CLUSTER_ID"=>"0",
           "DATASTORE"=>"default",
           "DATASTORE_ID"=>"1",
           "DEV_PREFIX"=>"vd",
           "DISK_ID"=>"0",
           "DISK_SNAPSHOT_TOTAL_SIZE"=>"0",
           "DISK_TYPE"=>"FILE",
           "DRIVER"=>"qcow2",
           "IMAGE"=>"octo-8-42-31-disk-0",
           "IMAGE_ID"=>"180",
           "IMAGE_STATE"=>"10",
           "LN_TARGET"=>"SYSTEM",
           "ORIGINAL_SIZE"=>"256",
           "PERSISTENT"=>"YES",
           "READONLY"=>"NO",
           "SAVE"=>"YES",
           "SIZE"=>"3072",
           "SOURCE"=>"/var/lib/one//datastores/1/16c2e7a21d1e4a24a1a015e5e05a318f",
           "TARGET"=>"vda",
           "TM_MAD"=>"ssh",
           "TYPE"=>"FILE"},
         "GRAPHICS"=>{"LISTEN"=>"0.0.0.0", "PORT"=>"6418", "TYPE"=>"VNC"},
         "MEMORY"=>"2048",
         "NIC"=>
          [{"AR_ID"=>"1",
            "BRIDGE"=>"br0",
            "BRIDGE_TYPE"=>"linux",
            "CLUSTER_ID"=>"0",
            "IP"=>"172.16.2.7",
            "MAC"=>"02:00:ac:10:02:07",
            "MODEL"=>"virtio",
            "NAME"=>"NIC0",
            "NETWORK"=>"br",
            "NETWORK_ID"=>"1",
            "NETWORK_UNAME"=>"oneadmin",
            "NIC_ID"=>"0",
            "SECURITY_GROUPS"=>"0",
            "TARGET"=>"one-518-0",
            "VN_MAD"=>"bridge"},
           {"AR_ID"=>"0",
            "BRIDGE"=>"onebr.3203",
            "BRIDGE_TYPE"=>"linux",
            "CLUSTER_ID"=>"0",
            "IP"=>"10.0.0.3",
            "MAC"=>"02:00:0a:00:00:03",
            "MODEL"=>"virtio",
            "MTU"=>"9000",
            "NAME"=>"NIC1",
            "NETWORK"=>"3203",
            "NETWORK_ID"=>"109",
            "NIC_ID"=>"1",
            "PHYDEV"=>"bond0",
            "SECURITY_GROUPS"=>"0",
            "TARGET"=>"one-518-1",
            "VLAN_ID"=>"3203",
            "VN_MAD"=>"802.1Q"}],
         "NIC_DEFAULT"=>{"MODEL"=>"virtio"},
         "OS"=>{"ARCH"=>"x86_64", "BOOT"=>""},
         "SECURITY_GROUP_RULE"=>
          [{"PROTOCOL"=>"ALL",
            "RULE_TYPE"=>"OUTBOUND",
            "SECURITY_GROUP_ID"=>"0",
            "SECURITY_GROUP_NAME"=>"default"},
           {"PROTOCOL"=>"ALL",
            "RULE_TYPE"=>"INBOUND",
            "SECURITY_GROUP_ID"=>"0",
            "SECURITY_GROUP_NAME"=>"default"}],
         "TEMPLATE_ID"=>"194",
         "TM_MAD_SYSTEM"=>"ssh",
         "VMID"=>"518"},
       "USER_TEMPLATE"=>
        {"INFO"=>
          "Please do not use this VM Template for vCenter VMs. Refer to the documentation https://bit.ly/37NcJ0Y",
         "INPUTS_ORDER"=>"",
         "LOGO"=>"images/logos/linux.png",
         "LXD_SECURITY_PRIVILEGED"=>"true",
         "MEMORY_UNIT_COST"=>"MB",
         "OCTOSHELL_BOUND_TO_TEMPLATE"=>"OCTOSHELL_BOUND_TO_TEMPLATE",
         "SCHED_DS_REQUIREMENTS"=>"ID=\"0\"",
         "USER"=>"root"},
       "HISTORY_RECORDS"=>
        {"HISTORY"=>
          [{"OID"=>"518",
            "SEQ"=>"0",
            "HOSTNAME"=>"vmnode30",
            "HID"=>"6",
            "CID"=>"0",
            "STIME"=>"1614117988",
            "ETIME"=>"1614118003",
            "VM_MAD"=>"kvm",
            "TM_MAD"=>"ssh",
            "DS_ID"=>"0",
            "PSTIME"=>"1614117988",
            "PETIME"=>"1614117991",
            "RSTIME"=>"1614117991",
            "RETIME"=>"1614118003",
            "ESTIME"=>"0",
            "EETIME"=>"0",
            "ACTION"=>"29",
            "UID"=>"0",
            "GID"=>"0",
            "REQUEST_ID"=>"5344"},
           {"OID"=>"518",
            "SEQ"=>"1",
            "HOSTNAME"=>"vmnode30",
            "HID"=>"6",
            "CID"=>"0",
            "STIME"=>"1614118003",
            "ETIME"=>"1614118400",
            "VM_MAD"=>"kvm",
            "TM_MAD"=>"ssh",
            "DS_ID"=>"0",
            "PSTIME"=>"0",
            "PETIME"=>"0",
            "RSTIME"=>"1614118003",
            "RETIME"=>"1614118400",
            "ESTIME"=>"0",
            "EETIME"=>"0",
            "ACTION"=>"23",
            "UID"=>"0",
            "GID"=>"0",
            "REQUEST_ID"=>"6512"},
           {"OID"=>"518",
            "SEQ"=>"2",
            "HOSTNAME"=>"vmnode30",
            "HID"=>"6",
            "CID"=>"0",
            "STIME"=>"1614118400",
            "ETIME"=>"1614258408",
            "VM_MAD"=>"kvm",
            "TM_MAD"=>"ssh",
            "DS_ID"=>"0",
            "PSTIME"=>"0",
            "PETIME"=>"0",
            "RSTIME"=>"1614118400",
            "RETIME"=>"1614258408",
            "ESTIME"=>"0",
            "EETIME"=>"0",
            "ACTION"=>"19",
            "UID"=>"0",
            "GID"=>"0",
            "REQUEST_ID"=>"4432"},
           {"OID"=>"518",
            "SEQ"=>"3",
            "HOSTNAME"=>"vmnode30",
            "HID"=>"6",
            "CID"=>"0",
            "STIME"=>"1614258404",
            "ETIME"=>"0",
            "VM_MAD"=>"kvm",
            "TM_MAD"=>"ssh",
            "DS_ID"=>"0",
            "PSTIME"=>"0",
            "PETIME"=>"0",
            "RSTIME"=>"1614258404",
            "RETIME"=>"0",
            "ESTIME"=>"0",
            "EETIME"=>"0",
            "ACTION"=>"0",
            "UID"=>"-1",
            "GID"=>"-1",
            "REQUEST_ID"=>"-1"}]}}
    end
  end
end
