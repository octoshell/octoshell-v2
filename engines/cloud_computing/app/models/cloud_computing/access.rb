module CloudComputing
  class Access < ApplicationRecord
    include Holder
    include AASM
    include ::AASM_Additions

    belongs_to :allowed_by, class_name: 'User'
    belongs_to :user

    belongs_to :request, inverse_of: :access
    # has_many :virtual_machines, through: :left_positions,
    #                             class_name: 'CloudComputing::NebulaIdentity',
    #                             source: :nebula_identities
    validates :for, :user, :allowed_by, presence: true
    validates :request_id, uniqueness: true, if: :request
    aasm(:state) do
      state :created, initial: true
      state :approved
      state :finished
      state :denied

      event :approve do
        transitions from: :created, to: :approved do
          guard do
            self.for && positions.exists? && positions_filled?
          end

          after do
            request.approve! if request
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


    def add_position(position)
      pos = positions.new(position.slice('item_id', 'amount'))
      position.resource_positions.each do |r_p|
        pos.resource_positions
           .build(r_p.attributes.slice('resource_id', 'value'))
      end
      pos
    end

    def virtual_machines
      NebulaIdentity.where(position: left_positions)
    end

    def copy_from_request
      return unless request

      self.for = request.for
      self.user = request.created_by
      pos_hash = Hash[request.positions.map do |position|
        [position, add_position(position)]
      end]

      request.positions.each do |position|
        from_position = pos_hash[position]
        position.from_links.each do |link|
          from_position.from_links.new(to: pos_hash[link.to],
                                       amount: link.amount)
        end
      end
    end

    def instantiate_vm
      # OpennebulaTask.instantiate_access(id)
      TaskWorker.perform_async(:instantiate_access, id)
    end

    def terminate_access
      # OpennebulaTask.terminate_access(id)
      TaskWorker.perform_async(:terminate_access, id)
    end

    def reinstantiate?
      left_positions.any? do |position|
        (position.amount - position.nebula_identities.count).positive?
      end
    end

    def add_keys
      # OpennebulaTask.add_keys(id)
      TaskWorker.perform_async(:add_keys, id)
    end


  end
end
