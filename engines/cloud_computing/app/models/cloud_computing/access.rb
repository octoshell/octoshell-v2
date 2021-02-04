module CloudComputing
  class Access < ApplicationRecord
    include Holder
    include AASM
    include ::AASM_Additions

    belongs_to :allowed_by, class_name: 'User'
    belongs_to :user

    has_many :requests, inverse_of: :access
    # has_many :virtual_machines, through: :left_items,
    #                             class_name: 'CloudComputing::NebulaIdentity',
    #                             source: :virtual_machines
    validates :for, :user, :allowed_by, presence: true
    # validates :request_id, uniqueness: true, if: :request
    aasm(:state) do
      state :created, initial: true
      state :approved
      state :finished
      state :denied

      event :approve do
        transitions from: :created, to: :approved do
          guard do
            self.for && items.exists? && items_filled?
          end

          after do
            requests.each(&:approve!)
            instantiate_vm
          end

        end
      end

      event :finish do
        transitions from: :approved, to: :finished
        after do
          terminate_access
        end
      end

      event :deny do
        transitions from: :approved, to: :denied
        after do
          terminate_access
        end
      end
    end


    def add_item(item)
      pos = items.new(item.slice('template_id'))
      item.resource_items.each do |r_p|
        pos.resource_items
           .build(r_p.attributes.slice('resource_id', 'value'))
      end
      pos
    end

    def virtual_machines
      VirtualMachine.where(item: left_items)
    end

    def copy_from_request(request)
      return unless request

      self.for = request.for
      self.user = request.created_by
      pos_hash = Hash[request.items.map do |item|
        [item, add_item(item)]
      end]

      request.items.each do |item|
        from_item = pos_hash[item]
        item.from_links.each do |link|
          from_item.from_links.new(to: pos_hash[link.to])
        end
      end
    end

    def instantiate_vm
      OpennebulaTask.instantiate_access(id)
      # TaskWorker.perform_async(:instantiate_access, id)
    end

    def terminate_access
      # OpennebulaTask.terminate_access(id)
      TaskWorker.perform_async(:terminate_access, id)
    end

    def reinstantiate?
      left_items.any? do |item|
        !item.virtual_machine
      end
    end

    def add_keys
      # OpennebulaTask.add_keys(id)
      TaskWorker.perform_async(:add_keys, id)
    end


  end
end
