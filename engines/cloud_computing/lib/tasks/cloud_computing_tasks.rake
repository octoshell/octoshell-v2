# desc "Explaining what the task does"
# task :cloud_computing do
#   # Task goes here
# end
namespace :cloud_computing do
  task create_positions: :environment do
    ActiveRecord::Base.transaction do
      pos = CloudComputing::Position.first
      puts 'aaa'.red
      pos.holder.update!(
        positions_attributes:
          {
            '1': {
              id: pos.id,
              from_links_attributes: {
                '1': {
                  to_attributes: {
                    item_id: 63
                  },
                  amount: 4
                }
              }

            }
          }
      )

      dqdqwad
    end
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
