# desc "Explaining what the task does"
# task :cloud_computing do
#   # Task goes here
# end
namespace :cloud_computing do
  task free_locks: :environment do
    CloudComputing::Item.for_users.each do |item|
      Redis::Semaphore.new(item.id, host: "localhost").delete!
    end
  end

  task prod_seed: :environment do
    ActiveRecord::Base.transaction do
      virtual_kind = CloudComputing::TemplateKind.create!(name_ru: 'Виртуальная машина',
                                                     name_en: 'Virtual machine',
                                                     cloud_class: CloudComputing::VirtualMachine.to_s)

      virtual_kind.resource_kinds.create!(name_ru: 'Оперативная память',
        name_en: 'Main Memory', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'MEMORY', content_type: 'positive_integer')

      virtual_kind.resource_kinds.create!(name_ru: 'Центральные процессоры',
        name_en: 'CPU', measurement_en: '', measurement_ru: '',
        identity: 'CPU', content_type: 'decimal',
        help_ru: 'Число процессоров: 0,5 - половина процессора, 2,0 - 2 процессора')


      virtual_kind.resource_kinds.create!(name_ru: 'Жёсткий диск',
        name_en: 'Hard drive', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'DISK=>SIZE', content_type: 'positive_integer')

      virtual_kind.resource_kinds.create!(name_ru: 'Доступ в Nнтернет',
        name_en: 'Internet access', measurement_en: 'GB', measurement_ru: 'GB',
        identity: 'DISK=>SIZE', content_type: 'positive_integer')

    end
    # TemplateKind.
  end

  task aaaa: :environment do
    pp Hash.from_xml(CloudComputing::OpennebulaClient.vm_info(518)[1])['VM']

  end

  task seed: :environment do
    ActiveRecord::Base.transaction do
      if CloudComputing::Cluster.all.count.zero?
        FactoryBot.create(:cloud_cluster, core_cluster: Core::Cluster.first)
      end
      cluster = CloudComputing::Cluster.first
      kinds = []
      kinds << FactoryBot.create(:cloud_item_kind, name: 'Virtual machines')
      kinds << FactoryBot.create(:cloud_item_kind, name: 'Discs')
      kinds << FactoryBot.create(:cloud_item_kind, name: 'Other')

      CloudComputing::Condition.create!(from: kinds[0], to: kinds[1], min: 1, max: 10, kind: 'required')
      CloudComputing::Condition.create!(from: kinds[0], to: kinds[2], min: 0, max: 10, kind: 'required')

      3.times do
        FactoryBot.create(:cloud_resource_kind)
      end

      3.times do |i|
        kinds.each do |kind|
          c_kind = FactoryBot.create(:cloud_item_kind, name: "Sub #{kind.name} #{i}",
                                                       parent: kind)
          30.times do |k|
            item = FactoryBot.create(:cloud_item, item_kind: c_kind,
                                                  cluster: cluster,
                                                  name: "Item #{i} #{k}")
            CloudComputing::ResourceKind.all.each do |r_k|
              FactoryBot.create(:cloud_resource, item: item, resource_kind: r_k)
            end
          end

        end
      end

    end
  end
end
