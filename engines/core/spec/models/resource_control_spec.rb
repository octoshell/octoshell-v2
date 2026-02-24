module Core
  require 'main_spec_helper'
  describe ResourceControl do
    describe 'calculate_resources' do
      it 'calculates resources' do
        allow_any_instance_of(Core::QueueAccessSynchronizerService).to receive(:run_on_cluster) do |_instance, command|
        end
        allow_any_instance_of(Core::QueueAccessSynchronizerService).to receive(:open_connection) { nil }
        allow_any_instance_of(Core::QueueAccessSynchronizerService).to receive(:close_connection) { nil }
        allow(Core::SshWorker).to receive(:perform_async) do |method, id|
          Core::QueueAccess.sync_with_cluster(id) if method == :sync_with_cluster
        end
        allow(ResourceControl).to receive(:usage_in_node_hours)
          .with(anything, anything)
          .and_return([
                        [2000, ''],
                        [500, ''],
                        [0, '']
                      ])

        access = create(:core_access)
        controller = create(:user)
        controller.groups.create(name: 'resource_controller')
        expect { ResourceControl.calculate_resources }
          .to change {
                access.reload.resource_controls.first.resource_control_fields.first.cur_value
              }.from(nil).to(2000.0)
                         .and send_email(
                           to: controller.email
                         )
      end
    end
  end
end
