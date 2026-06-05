require 'main_spec_helper'

module Core
  RSpec.describe ClusterStatsService do
    let(:cluster) { create(:cluster) }
    let(:start_date) { Date.new(2025, 1, 1) }
    let(:end_date) { Date.new(2025, 3, 31) }

    # Helper to create a service instance
    def build_service(group_by: 'login', period_group: 'none')
      ClusterStatsService.new(cluster, start_date, end_date, group_by, period_group)
    end

    # Helper to mock sacct via cluster.execute
    def stub_sacct(output, stderr = '')
      allow(cluster).to receive(:execute).and_return([output, stderr])
    end

    # ============================================
    # Parsing sacct output
    # ============================================
    describe '#parse_sacct_output' do
      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|2|01:30:00|2025-01-15T08:00:00|COMPLETED|compute
          user2|12346|4|2-12:00:00|2025-01-16T10:00:00|COMPLETED|gpu
          user3|12347|1|45:00|2025-01-17T12:00:00|COMPLETED|batch
        OUTPUT
      end

      it 'parses HH:MM:SS format correctly' do
        stub_sacct(sacct_output)
        result = build_service.call
        user1_row = result[:rows].find { |r| r[:key] == 'user1' }
        expect(user1_row[:total][:node_hours]).to be_within(0.01).of(3.0) # 1.5h * 2 nodes
      end

      it 'parses DD-HH:MM:SS format correctly' do
        stub_sacct(sacct_output)
        result = build_service.call
        user2_row = result[:rows].find { |r| r[:key] == 'user2' }
        # 2d 12h = 60h * 4 nodes = 240 node-hours
        expect(user2_row[:total][:node_hours]).to be_within(0.01).of(240.0)
      end

      it 'parses MM:SS format correctly' do
        stub_sacct(sacct_output)
        result = build_service.call
        user3_row = result[:rows].find { |r| r[:key] == 'user3' }
        # 45min = 0.75h * 1 node = 0.75 node-hours
        expect(user3_row[:total][:node_hours]).to be_within(0.01).of(0.75)
      end
    end

    # ============================================
    # Filtering CANCELLED with zero time
    # ============================================
    describe 'CANCELLED jobs with zero time' do
      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|2|00:00:00|2025-01-15T08:00:00|CANCELLED|compute
          user1|12346|2|01:30:00|2025-01-15T08:00:00|COMPLETED|compute
        OUTPUT
      end

      it 'skips CANCELLED jobs with zero elapsed time' do
        stub_sacct(sacct_output)
        result = build_service.call
        expect(result[:rows].size).to eq(1)
        expect(result[:rows].first[:key]).to eq('user1')
        expect(result[:rows].first[:total][:node_hours]).to be_within(0.01).of(3.0)
      end
    end

    # ============================================
    # JobID with dot (child job)
    # ============================================
    describe 'JobID with dot (child job)' do
      let(:sacct_output) do
        <<~OUTPUT
          user1|12345.batch|2|01:30:00|2025-01-15T08:00:00|COMPLETED|compute
        OUTPUT
      end

      it 'raises ClusterStatsError' do
        stub_sacct(sacct_output)
        expect { build_service.call }.to raise_error(ClusterStatsError, /Child job detected/)
      end
    end

    # ============================================
    # SLURM stderr error
    # ============================================
    describe 'SLURM stderr error' do
      it 'raises ClusterStatsError when stderr is present' do
        stub_sacct('', 'slurm error: connection failed')
        expect { build_service.call }.to raise_error(ClusterStatsError, /SLURM error/)
      end
    end

    # ============================================
    # Grouping by login (without period_group)
    # ============================================
    describe 'grouping by login' do
      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|2|01:00:00|2025-01-15T08:00:00|COMPLETED|compute
          user1|12346|4|00:30:00|2025-01-16T10:00:00|COMPLETED|gpu
          user2|12347|1|02:00:00|2025-01-17T12:00:00|COMPLETED|batch
        OUTPUT
      end

      it 'groups by login and calculates totals' do
        stub_sacct(sacct_output)
        result = build_service.call

        expect(result[:source]).to eq(:slurm)
        expect(result[:rows].size).to eq(2)

        user1_row = result[:rows].find { |r| r[:key] == 'user1' }
        # 2*1 + 4*0.5 = 2 + 2 = 4 node-hours
        expect(user1_row[:total][:node_hours]).to be_within(0.01).of(4.0)
        expect(user1_row[:total][:job_count]).to eq(2)

        user2_row = result[:rows].find { |r| r[:key] == 'user2' }
        # 1*2 = 2 node-hours
        expect(user2_row[:total][:node_hours]).to be_within(0.01).of(2.0)
        expect(user2_row[:total][:job_count]).to eq(1)
      end

      it 'calculates total aggregation' do
        stub_sacct(sacct_output)
        result = build_service.call

        expect(result[:total][:node_hours]).to be_within(0.01).of(6.0)
        expect(result[:total][:job_count]).to eq(3)
      end

      it 'includes partition breakdown in each row' do
        stub_sacct(sacct_output)
        result = build_service.call

        user1_row = result[:rows].find { |r| r[:key] == 'user1' }
        expect(user1_row[:partitions]).to have_key('compute')
        expect(user1_row[:partitions]).to have_key('gpu')
        # user1: compute 2*1=2, gpu 4*0.5=2
        expect(user1_row[:partitions]['compute'][:node_hours]).to be_within(0.01).of(2.0)
        expect(user1_row[:partitions]['gpu'][:node_hours]).to be_within(0.01).of(2.0)

        user2_row = result[:rows].find { |r| r[:key] == 'user2' }
        expect(user2_row[:partitions]).to have_key('batch')
        expect(user2_row[:partitions]['batch'][:node_hours]).to be_within(0.01).of(2.0)
      end

      it 'lists partition_columns in result' do
        stub_sacct(sacct_output)
        result = build_service.call

        expect(result[:partition_columns]).to match_array(%w[batch compute gpu])
      end
    end

    # ============================================
    # Grouping by project (via Member)
    # ============================================
    describe 'grouping by project' do
      let!(:project) { create(:project) }
      before do
        # Override the member_owner login to a known value for testing
        project.member_owner.update_column(:login, 'known_owner_login')
      end

      let(:sacct_output) do
        <<~OUTPUT
          known_owner_login|12345|2|01:00:00|2025-01-15T08:00:00|COMPLETED|compute
          user2|12346|1|02:00:00|2025-01-16T10:00:00|COMPLETED|batch
        OUTPUT
      end

      it 'groups by project using Member mapping' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'project').call

        # known_owner_login -> project title (via project.organization)
        proj_row = result[:rows].find { |r| r[:key] == project.id_with_title }
        expect(proj_row).not_to be_nil
        expect(proj_row[:total][:node_hours]).to be_within(0.01).of(2.0)

        # user2 not in member -> hidden (unmapped logins are skipped)
        user2_row = result[:rows].find { |r| r[:key] == 'user2' }
        expect(user2_row).to be_nil
        expect(result[:rows].size).to eq(1)
      end
    end

    # ============================================
    # Time breakdown by month (period_group: 'month')
    # ============================================
    describe 'period grouping by month' do
      let(:start_date) { Date.new(2025, 1, 1) }
      let(:end_date) { Date.new(2025, 2, 28) }

      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|2|720:00:00|2025-01-15T00:00:00|COMPLETED|compute
        OUTPUT
      end
      # task of 720h (30 days), starts Jan 15
      # The task belongs entirely to January (its start month).
      # January: 720h * 2 nodes = 1440 node-hours
      # February: 0

      it 'assigns the task to its start month' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'login', period_group: 'month').call

        expect(result[:columns]).to eq(%w[2025-01 2025-02])
        expect(result[:rows].size).to eq(1)

        row = result[:rows].first
        expect(row[:key]).to eq('user1')

        jan_cell = row[:cells]['2025-01']
        # 720h * 2 nodes = 1440
        expect(jan_cell[:total][:node_hours]).to be_within(0.01).of(1440.0)
        expect(jan_cell[:total][:job_count]).to eq(1)

        feb_cell = row[:cells]['2025-02']
        # No tasks started in February
        expect(feb_cell[:total][:node_hours]).to eq(0.0)
        expect(feb_cell[:total][:job_count]).to eq(0)
      end

      it 'calculates total across all periods' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'login', period_group: 'month').call

        expect(result[:total][:node_hours]).to be_within(0.01).of(1440.0) # 720h * 2 nodes
        expect(result[:total][:job_count]).to eq(1)
      end

      it 'includes partition breakdown in period cells' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'login', period_group: 'month').call

        row = result[:rows].first
        jan_cell = row[:cells]['2025-01']
        expect(jan_cell[:partitions]).to have_key('compute')
        expect(jan_cell[:partitions]['compute'][:node_hours]).to be_within(0.01).of(1440.0)
      end
    end

    # ============================================
    # Time breakdown by quarter (period_group: 'quarter')
    # ============================================
    describe 'period grouping by quarter' do
      let(:start_date) { Date.new(2025, 2, 1) }
      let(:end_date) { Date.new(2025, 4, 30) }

      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|2|2160:00:00|2025-02-01T00:00:00|COMPLETED|compute
        OUTPUT
      end
      # task of 2160h (90 days), starts Feb 1
      # The task belongs entirely to Q1 2025 (its start quarter).
      # Q1 2025: 2160h * 2 nodes = 4320 node-hours
      # Q2 2025: 0

      it 'assigns the task to its start quarter' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'login', period_group: 'quarter').call

        expect(result[:columns]).to eq(['Q1 2025', 'Q2 2025'])
        expect(result[:rows].size).to eq(1)

        row = result[:rows].first
        expect(row[:key]).to eq('user1')

        q1_cell = row[:cells]['Q1 2025']
        # 2160h * 2 nodes = 4320
        expect(q1_cell[:total][:node_hours]).to be_within(0.01).of(4320.0)
        expect(q1_cell[:total][:job_count]).to eq(1)

        q2_cell = row[:cells]['Q2 2025']
        # No tasks started in Q2
        expect(q2_cell[:total][:node_hours]).to eq(0.0)
        expect(q2_cell[:total][:job_count]).to eq(0)
      end
    end

    # ============================================
    # Grouping by organization with 3 orgs, 2 users per org, plus unmapped root user
    # ============================================
    describe 'grouping by organization with 3 orgs and 3 months' do
      let(:start_date) { Date.new(2025, 1, 1) }
      let(:end_date) { Date.new(2025, 3, 31) }

      let!(:org_a) { create(:organization, name: 'Org A') }
      let!(:org_b) { create(:organization, name: 'Org B') }
      let!(:org_c) { create(:organization, name: 'Org C') }

      let!(:project_a) { create(:project, organization: org_a) }
      let!(:project_b) { create(:project, organization: org_b) }
      let!(:project_c) { create(:project, organization: org_c) }

      # Additional users for each project
      let!(:user_a2) { create(:user, email: 'user_a2@test.ru') }
      let!(:user_b2) { create(:user, email: 'user_b2@test.ru') }
      let!(:user_c2) { create(:user, email: 'user_c2@test.ru') }

      before do
        # Override member_owner logins to match sacct usernames
        project_a.member_owner.update_column(:login, 'user_a1')
        project_b.member_owner.update_column(:login, 'user_b1')
        project_c.member_owner.update_column(:login, 'user_c1')

        # Create additional members for each project
        m_a2 = Core::Member.create!(project: project_a, user: user_a2, organization: org_a)
        m_a2.update_column(:login, 'user_a2')
        m_b2 = Core::Member.create!(project: project_b, user: user_b2, organization: org_b)
        m_b2.update_column(:login, 'user_b2')
        m_c2 = Core::Member.create!(project: project_c, user: user_c2, organization: org_c)
        m_c2.update_column(:login, 'user_c2')
      end

      let(:sacct_output) do
        <<~OUTPUT
          # --- Org A ---
          # user_a1: 2 nodes, 720h (30 days), starts Jan 10, partition compute
          #   Jan 10-31 = 22 days = 528h * 2 = 1056 nh
          #   Feb 1-9   =  8 days = 192h * 2 =  384 nh
          user_a1|1001|2|720:00:00|2025-01-10T00:00:00|COMPLETED|compute
          # user_a2: 1 node, 360h (15 days), starts Jan 20, partition gpu
          #   Jan 20-31 = 12 days = 288h * 1 =  288 nh
          #   Feb 1-4   =  4 days =  96h * 1 =   96 nh
          user_a2|1002|1|360:00:00|2025-01-20T00:00:00|COMPLETED|gpu
          # --- Org B ---
          # user_b1: 4 nodes, 360h (15 days), starts Feb 1, partition gpu
          #   Feb 1-15 = 15 days = 360h * 4 = 1440 nh
          user_b1|1003|4|360:00:00|2025-02-01T00:00:00|COMPLETED|gpu
          # user_b2: 2 nodes, 144h (6 days), starts Feb 10, partition compute
          #   Feb 10-15 = 6 days = 144h * 2 = 288 nh
          user_b2|1004|2|144:00:00|2025-02-10T00:00:00|COMPLETED|compute
          # --- Org C ---
          # user_c1: 1 node, 1440h (60 days), starts Jan 5, partition batch
          #   Jan 5-31  = 27 days = 648h * 1 =  648 nh
          #   Feb 1-28  = 28 days = 672h * 1 =  672 nh
          #   Mar 1-5   =  5 days = 120h * 1 =  120 nh
          user_c1|1005|1|1440:00:00|2025-01-05T00:00:00|COMPLETED|batch
          # user_c2: 3 nodes, 48h (2 days), starts Mar 10, partition gpu
          #   Mar 10-11 = 2 days = 48h * 3 = 144 nh
          user_c2|1006|3|48:00:00|2025-03-10T00:00:00|COMPLETED|gpu
          # --- Unmapped user (not in Octoshell) ---
          # root: 8 nodes, 24h (1 day), starts Jan 15, partition compute
          root|1007|8|24:00:00|2025-01-15T00:00:00|COMPLETED|compute
        OUTPUT
      end

      it 'groups by organization and splits across 3 months, hides unmapped root' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'organization', period_group: 'month').call

        expect(result[:source]).to eq(:slurm)
        expect(result[:columns]).to eq(%w[2025-01 2025-02 2025-03])

        # 3 organizations (root is hidden)
        expect(result[:rows].size).to eq(3)

        # --- Org A (user_a1 + user_a2) ---
        row_a = result[:rows].find { |r| r[:key] == org_a.to_s }
        expect(row_a).not_to be_nil

        # Both user_a1 and user_a2 started in January
        # user_a1: 720h * 2 = 1440, user_a2: 360h * 1 = 360
        expect(row_a[:cells]['2025-01'][:total][:node_hours]).to be_within(0.01).of(1800.0)
        expect(row_a[:cells]['2025-01'][:total][:job_count]).to eq(2)

        # No tasks started in February or March
        expect(row_a[:cells]['2025-02'][:total][:node_hours]).to eq(0.0)
        expect(row_a[:cells]['2025-02'][:total][:job_count]).to eq(0)
        expect(row_a[:cells]['2025-03'][:total][:node_hours]).to eq(0.0)
        expect(row_a[:cells]['2025-03'][:total][:job_count]).to eq(0)

        # Partition breakdown for Org A
        expect(row_a[:cells]['2025-01'][:partitions]['compute'][:node_hours]).to be_within(0.01).of(1440.0)
        expect(row_a[:cells]['2025-01'][:partitions]['gpu'][:node_hours]).to be_within(0.01).of(360.0)

        # --- Org B (user_b1 + user_b2) ---
        row_b = result[:rows].find { |r| r[:key] == org_b.to_s }
        expect(row_b).not_to be_nil

        # Both user_b1 and user_b2 started in February
        # user_b1: 360h * 4 = 1440, user_b2: 144h * 2 = 288
        expect(row_b[:cells]['2025-02'][:total][:node_hours]).to be_within(0.01).of(1728.0)
        expect(row_b[:cells]['2025-02'][:total][:job_count]).to eq(2)

        # No tasks started in January or March
        expect(row_b[:cells]['2025-01'][:total][:node_hours]).to eq(0.0)
        expect(row_b[:cells]['2025-01'][:total][:job_count]).to eq(0)
        expect(row_b[:cells]['2025-03'][:total][:node_hours]).to eq(0.0)
        expect(row_b[:cells]['2025-03'][:total][:job_count]).to eq(0)

        # Partition breakdown for Org B
        expect(row_b[:cells]['2025-02'][:partitions]['gpu'][:node_hours]).to be_within(0.01).of(1440.0)
        expect(row_b[:cells]['2025-02'][:partitions]['compute'][:node_hours]).to be_within(0.01).of(288.0)

        # --- Org C (user_c1 + user_c2) ---
        row_c = result[:rows].find { |r| r[:key] == org_c.to_s }
        expect(row_c).not_to be_nil

        # user_c1 started in January: 1440h * 1 = 1440
        expect(row_c[:cells]['2025-01'][:total][:node_hours]).to be_within(0.01).of(1440.0)
        expect(row_c[:cells]['2025-01'][:total][:job_count]).to eq(1)

        # No tasks started in February
        expect(row_c[:cells]['2025-02'][:total][:node_hours]).to eq(0.0)
        expect(row_c[:cells]['2025-02'][:total][:job_count]).to eq(0)

        # user_c2 started in March: 48h * 3 = 144
        expect(row_c[:cells]['2025-03'][:total][:node_hours]).to be_within(0.01).of(144.0)
        expect(row_c[:cells]['2025-03'][:total][:job_count]).to eq(1)

        # Partition breakdown for Org C
        expect(row_c[:cells]['2025-01'][:partitions]['batch'][:node_hours]).to be_within(0.01).of(1440.0)
        expect(row_c[:cells]['2025-03'][:partitions]['gpu'][:node_hours]).to be_within(0.01).of(144.0)

        # --- root should NOT appear in results ---
        root_row = result[:rows].find { |r| r[:key] == 'root' }
        expect(root_row).to be_nil
      end

      it 'calculates total across all orgs and months, excluding root' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'organization', period_group: 'month').call

        # user_a1: 720h * 2 = 1440 (started Jan)
        # user_a2: 360h * 1 =  360 (started Jan)
        # user_b1: 360h * 4 = 1440 (started Feb)
        # user_b2: 144h * 2 =  288 (started Feb)
        # user_c1: 1440h * 1 = 1440 (started Jan)
        # user_c2:  48h * 3 =  144 (started Mar)
        # total: 1440+360+1440+288+1440+144 = 5112
        # root: 24h * 8 = 192 (excluded)
        expect(result[:total][:node_hours]).to be_within(0.01).of(5112.0)
        expect(result[:total][:job_count]).to eq(6)
      end

      it 'includes partition_columns with all partitions' do
        stub_sacct(sacct_output)
        result = build_service(group_by: 'organization', period_group: 'month').call

        expect(result[:partition_columns]).to match_array(%w[batch compute gpu])
      end
    end

    # ============================================
    # Empty sacct output
    # ============================================
    describe 'empty sacct output' do
      it 'returns empty result' do
        stub_sacct('')
        result = build_service.call

        expect(result[:rows]).to be_empty
        expect(result[:total][:node_hours]).to eq(0.0)
        expect(result[:total][:job_count]).to eq(0)
      end
    end

    # ============================================
    # Malformed sacct lines
    # ============================================
    describe 'malformed sacct lines' do
      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|2|invalid|2025-01-15T08:00:00|COMPLETED|compute
          user2|12346|abc|01:00:00|2025-01-16T10:00:00|COMPLETED|gpu
          |||||
        OUTPUT
      end

      it 'skips malformed lines' do
        stub_sacct(sacct_output)
        result = build_service.call

        expect(result[:rows]).to be_empty
        expect(result[:total][:node_hours]).to eq(0.0)
        expect(result[:total][:job_count]).to eq(0)
      end
    end

    # ============================================
    # Result sorting by node_hours descending
    # ============================================
    describe 'result sorting' do
      let(:sacct_output) do
        <<~OUTPUT
          user1|12345|1|01:00:00|2025-01-15T08:00:00|COMPLETED|compute
          user2|12346|1|05:00:00|2025-01-16T10:00:00|COMPLETED|gpu
          user3|12347|1|02:00:00|2025-01-17T12:00:00|COMPLETED|batch
        OUTPUT
      end

      it 'sorts rows by total node_hours descending' do
        stub_sacct(sacct_output)
        result = build_service.call

        keys = result[:rows].map { |r| r[:key] }
        expect(keys).to eq(%w[user2 user3 user1])
      end
    end
  end
end
