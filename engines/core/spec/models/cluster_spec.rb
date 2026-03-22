require 'main_spec_helper'

module Core
  RSpec.describe Cluster do
    let(:cluster) { create(:cluster) }

    describe '#expand_node_names' do
      context 'when node name is a single node without range' do
        it 'returns the node name as is' do
          expect(cluster.send(:expand_node_names, 'node001')).to eq(['node001'])
        end
      end

      context 'when node name contains a range' do
        it 'expands the range into individual node names' do
          result = cluster.send(:expand_node_names, 'n[54107-54110]')
          expect(result).to eq(%w[n54107 n54108 n54109 n54110])
        end
      end

      context 'when node name contains multiple ranges and single numbers' do
        it 'expands all ranges and includes single numbers' do
          result = cluster.send(:expand_node_names, 'n[54103,54107-54110,54115-54117]')
          expect(result).to eq(%w[n54103 n54107 n54108 n54109 n54110 n54115 n54116 n54117])
        end
      end

      context 'when node name has complex format like in the example' do
        it 'correctly expands complex ranges' do
          input = 'n[54103,54107-54110,54115-54125,54127,54129,54131,54201-54202]'
          result = cluster.send(:expand_node_names, input)
          expect(result).to include('n54103', 'n54107', 'n54110', 'n54115', 'n54125', 'n54127', 'n54129', 'n54131',
                                    'n54201', 'n54202')
        end
      end

      context 'when node name has different prefix' do
        it 'uses the correct prefix for all expanded names' do
          result = cluster.send(:expand_node_names, 'compute[1-3]')
          expect(result).to eq(%w[compute1 compute2 compute3])
        end
      end
    end

    describe '#log_node_states' do
      let(:partition_name) { 'batch' }
      let(:sinfo_output) do
        <<~OUTPUT
          node001 #{partition_name} idle~ None
          node002 #{partition_name} down~ Hardware failure
          n[54103-54105] #{partition_name} allocated~ None
        OUTPUT
      end

      before do
        allow(cluster).to receive(:execute).with('sudo /usr/octo/sinfo_log_nodes').and_return([sinfo_output, ''])
      end

      it 'creates nodes and updates their states' do
        expect { cluster.log_node_states }.to change {
          Core::Node.count
        }.by(5) # node001, node002, n54103, n54104, n54105

        expect(Core::Node.find_by(name: 'node001')&.current_state).to eq('idle~')
        expect(Core::Node.find_by(name: 'node002')&.current_state).to eq('down~')
        expect(Core::Node.find_by(name: 'node002')&.current_reason).to eq('Hardware failure')
      end

      it 'associates nodes with partitions' do
        cluster.log_node_states

        node = Core::Node.find_by(name: 'node001')
        partition = Core::Partition.find_by(cluster: cluster, name: partition_name)
        expect(node.partitions).to include(partition)
      end

      context 'when sinfo returns stderr' do
        before do
          allow(cluster).to receive(:execute).and_return(['', 'Error occurred'])
        end

        it 'raises an error' do
          expect { cluster.log_node_states }.to raise_error(RuntimeError, /Error when retrieving sinfo/)
        end

        it 'does not create any nodes' do
          expect do
            cluster.log_node_states
          rescue StandardError
            nil
          end.not_to(change { Core::Node.count })
        end
      end

      context 'when state changes between allocated and idle' do
        let(:node) { create(:node, cluster: cluster, name: 'test_node_allocated') }
        let!(:existing_state) { create(:node_state, node: node, state: 'idle', reason: nil) }

        let(:sinfo_output) do
          <<~OUTPUT
            test_node_allocated batch allocated
          OUTPUT
        end

        before do
          allow(cluster).to receive(:execute).with('sudo /usr/octo/sinfo_log_nodes').and_return([sinfo_output, ''])
        end

        it 'does not create a new state (treats allocated and idle as equivalent)' do
          cluster.log_node_states

          expect(node.node_states.count).to eq(1)
        end
      end

      context 'when node already exists with the same state' do
        let(:node) { create(:node, cluster: cluster, name: 'test_node_same_state') }
        let!(:existing_state) { create(:node_state, node: node, state: 'idle~', reason: nil) }

        let(:sinfo_output) do
          <<~OUTPUT
            test_node_same_state batch idle~
          OUTPUT
        end

        before do
          allow(cluster).to receive(:execute).with('sudo /usr/octo/sinfo_log_nodes').and_return([sinfo_output, ''])
        end

        it 'does not create a new state' do
          cluster.log_node_states

          expect(node.node_states.count).to eq(1)
        end
      end

      context 'when node state changes' do
        let(:node) { create(:node, cluster: cluster, name: 'test_node_state_change') }
        let!(:existing_state) { create(:node_state, node: node, state: 'idle~') }

        let(:sinfo_output) do
          <<~OUTPUT
            test_node_state_change batch down~ Hardware issue
          OUTPUT
        end

        before do
          allow(cluster).to receive(:execute).with('sudo /usr/octo/sinfo_log_nodes').and_return([sinfo_output, ''])
        end

        it 'creates a new state' do
          cluster.log_node_states

          expect(node.node_states.reload.count).to eq(2)
          expect(node.node_states.reload.order(:state_time).last.state).to eq('down~')
        end
      end
    end
    describe '#nodehours_by_login' do
      let(:start_time) { Time.zone.parse('2025-01-01 00:00:00') }
      let(:end_time) { Time.zone.parse('2025-01-02 00:00:00') }

      context 'when jobs_in_period returns valid data' do
        let(:sacct_output) do
          <<~OUTPUT
            user1|batch|1-12:30:00|2|2025-01-01T00:00:00|2025-01-01T12:30:00|COMPLETED
            user2|gpu|12:30:00|1|2025-01-01T00:00:00|2025-01-01T12:30:00|COMPLETED
            user1|batch|00:30:00|4|2025-01-01T00:00:00|2025-01-01T00:30:00|COMPLETED
          OUTPUT
        end

        before do
          allow(cluster).to receive(:jobs_in_period).with(start_time, end_time).and_return(sacct_output)
        end

        it 'calculates node-hours per login correctly' do
          result = cluster.nodehours_by_login(start_time, end_time)

          # user1: first job: 1 day 12h30m = 36.5 hours, nodes=2 => 73 node-hours
          #        second job: 0.5 hours, nodes=4 => 2 node-hours
          # total for user1 = 75 node-hours
          # user2: 12h30m = 12.5 hours, nodes=1 => 12.5 node-hours
          expect(result['user1']).to be_within(0.01).of(75.0)
          expect(result['user2']).to be_within(0.01).of(12.5)
        end
      end

      context 'when jobs_in_period returns empty output' do
        before do
          allow(cluster).to receive(:jobs_in_period).with(start_time, end_time).and_return('')
        end

        it 'returns empty hash' do
          expect(cluster.nodehours_by_login(start_time, end_time)).to eq({})
        end
      end

      context 'when jobs_in_period returns malformed lines' do
        let(:sacct_output) do
          <<~OUTPUT
            user1|batch|invalid|2|2025-01-01T00:00:00|2025-01-01T12:30:00|COMPLETED
            user2|gpu|12:30:00|not_a_number|2025-01-01T00:00:00|2025-01-01T12:30:00|COMPLETED
            |||||
          OUTPUT
        end

        before do
          allow(cluster).to receive(:jobs_in_period).with(start_time, end_time).and_return(sacct_output)
        end

        it 'skips invalid lines and returns empty hash' do
          result = cluster.nodehours_by_login(start_time, end_time)
          expect(result).to eq({})
        end
      end

      context 'when jobs_in_period raises error' do
        before do
          allow(cluster).to receive(:jobs_in_period).with(start_time, end_time)
                                                    .and_raise(RuntimeError, 'Error when retrieving jobs_in_period: something')
        end

        it 'propagates the error' do
          expect { cluster.nodehours_by_login(start_time, end_time) }
            .to raise_error(RuntimeError, /Error when retrieving jobs_in_period/)
        end
      end
    end
  end
end
