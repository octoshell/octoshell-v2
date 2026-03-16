module Core
  require 'main_spec_helper'
  describe ResourceControl do
    before(:each) do
      # Mock all SSH and cluster synchronization to avoid external connections
      allow_any_instance_of(Core::QueueAccessSynchronizerService).to receive(:run_on_cluster)
      allow_any_instance_of(Core::QueueAccessSynchronizerService).to receive(:open_connection).and_return(nil)
      allow_any_instance_of(Core::QueueAccessSynchronizerService).to receive(:close_connection)
      allow(Core::QueueAccess).to receive(:sync_with_cluster).and_return(nil)
      allow(Core::SshWorker).to receive(:perform_async)
    end

    describe 'AASM states' do
      let(:resource_control) { create(:resource_control) }

      it 'has initial state pending' do
        expect(resource_control).to be_pending
      end

      it 'transitions from pending to active' do
        resource_control.activate!
        expect(resource_control).to be_active
      end

      it 'transitions from active to blocked' do
        resource_control.activate!
        resource_control.block!
        expect(resource_control).to be_blocked
      end

      it 'transitions from blocked to active' do
        resource_control.activate!
        resource_control.block!
        resource_control.unblock!
        expect(resource_control).to be_active
      end

      it 'does not have disabled state' do
        expect(resource_control).not_to respond_to(:disabled?)
        expect(resource_control).not_to respond_to(:disabled!)
      end

      it 'synchronizes queue_accesses after state transition' do
        allow(resource_control).to receive(:sync_queue_accesses)
        resource_control.activate!
        expect(resource_control).to have_received(:sync_queue_accesses)
      end
    end

    describe '.calculate_resources' do
      it 'calculates resources and updates resource_control_fields' do
        allow(ResourceControl).to receive(:usage_in_node_hours)
          .with(anything, anything)
          .and_return([
                        [2000, ''],
                        [500, ''],
                        [0, '']
                      ])

        access = create(:core_access)
        expect { ResourceControl.calculate_resources }
          .to change {
                access.reload.resource_controls.first.resource_control_fields.first.cur_value
              }.from(nil).to(2000.0)
        # Email should NOT be sent by calculate_resources
      end
    end

    describe '.send_resource_usage_emails' do
      let(:access) { create(:core_access) }
      let(:project) { access.project }
      let(:member) { create(:core_member, project: project) }
      let(:resource_user_with_member) { create(:core_resource_user, access: access, member: member) }
      let(:resource_user_with_email) { create(:core_resource_user, access: access, email: 'external@example.com') }
      let(:controller) { create(:user) }

      before do
        controller.groups.create!(name: 'resource_controller')
        resource_user_with_member
        resource_user_with_email
      end

      it 'sends emails to all recipients' do
        expect { ResourceControl.send_resource_usage_emails }
          .to send_email(to: member.user.email)
          .and send_email(to: 'external@example.com')
          .and send_email(to: controller.email)
      end
    end
  end
end
