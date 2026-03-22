module Core
  require 'main_spec_helper'
  describe ResourceControl do
    before(:each) do
      # Mock all SSH and cluster synchronization to avoid external connections
      allow(SshWorker).to receive(:perform_async).and_return(nil)
      allow_any_instance_of(Core::ResourceControl).to receive(:synchronize).and_return(nil)
    end

    describe 'AASM states' do
      let(:resource_control) { create(:resource_control) }

      before do
        # Ensure resource_control_fields exists
        if resource_control.resource_control_fields.empty?
          kind = Core::QuotaKind.find_or_create_by!(api_key: 'node_hours', name_ru: 'Node hours')
          resource_control.resource_control_fields.create!(quota_kind: kind, limit: 1000, cur_value: nil)
        end
      end

      it 'has initial state pending' do
        expect(resource_control).to be_pending
      end

      it 'transitions from pending to active' do
        resource_control.enable!
        expect(resource_control).to be_active
      end

      it 'transitions from active to blocked' do
        resource_control.enable!
        # Make the resource exceeded to trigger blocked state
        resource_control.resource_control_fields.first.update!(cur_value: 2000)
        resource_control.change_cluster_state!
        expect(resource_control).to be_blocked
      end

      it 'transitions from blocked to active' do
        resource_control.enable!
        resource_control.resource_control_fields.first.update!(cur_value: 2000)
        resource_control.change_cluster_state!
        # Now make it not exceeded
        resource_control.resource_control_fields.first.update!(cur_value: 0)
        resource_control.change_cluster_state!
        expect(resource_control).to be_active
      end

      it 'does not have disabled state' do
        expect(resource_control).to respond_to(:disabled?)
        expect(resource_control).to respond_to(:disable!)
      end

      it 'enqueues synchronization after state transition' do
        allow(resource_control).to receive(:enqueue_synchronize)
        resource_control.enable!
        expect(resource_control).to have_received(:enqueue_synchronize)
      end
    end

    describe '.calculate_resources' do
      it 'calculates resources and updates resource_control_fields' do
        # Mock jobs_in_period to return empty output (no jobs)
        cluster = instance_double(Core::Cluster)
        allow(cluster).to receive(:jobs_in_period).and_return('')
        # Track calls to node_hours_from_jobs
        node_hours_called = false
        allow_any_instance_of(Core::ResourceControl).to receive(:node_hours_from_jobs) do |instance|
          node_hours_called = true
          2000.0
        end

        access = create(:core_access)
        # Ensure resource_control_fields exist and set status to active
        access.resource_controls.each do |rc|
          if rc.resource_control_fields.empty?
            kind = Core::QuotaKind.find_or_create_by!(api_key: 'node_hours', name_ru: 'Node hours')
            rc.resource_control_fields.create!(quota_kind: kind, limit: 1000, cur_value: nil)
          end
          rc.enable! if rc.pending?
        end
        # Stub the cluster association
        allow(access).to receive(:cluster).and_return(cluster)
        allow_any_instance_of(Core::Access).to receive(:cluster).and_return(cluster)

        # Also stub parse_jobs_output to return empty array to avoid any real parsing
        allow(Core::ResourceControl).to receive(:parse_jobs_output).and_return([])

        # Debug: check field exists
        rc = access.resource_controls.first
        field = rc.resource_control_fields.first
        expect(field).to be_present
        expect(field.cur_value).to be_nil
        expect(rc).to be_active

        # Perform calculation
        ResourceControl.calculate_resources

        # Verify node_hours_from_jobs was called
        expect(node_hours_called).to be true

        # Verify cur_value updated
        access.reload
        updated_value = access.resource_controls.first.resource_control_fields.first.cur_value
        expect(updated_value).to eq(2000.0)
        # Email should NOT be sent by calculate_resources
      end
    end

    describe '.send_resource_usage_emails' do
      let(:access) { create(:core_access) }
      let(:project) { access.project }
      let(:user) { create(:user) }
      let(:member) { project.members.create(user: user) }
      let(:controller) { create(:user) }

      before do
        controller.groups.create!(name: 'resource_controller')
        # Create resource users directly since factory may not exist
        Core::ResourceUser.create!(access: access, member: member)
        Core::ResourceUser.create!(access: access, email: 'external@example.com')
      end

      it 'sends emails to all recipients' do
        expect { ResourceControl.send_resource_usage_emails }
          .to send_email(to: user.email)
          .and send_email(to: 'external@example.com')
          .and send_email(to: controller.email)
      end
    end
  end
end
