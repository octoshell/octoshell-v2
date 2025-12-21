module Core
  require 'main_spec_helper'
  describe NodeHourCounterService do
    it "counts node hours" do
      service = NodeHourCounterService.new(Core::Cluster.first,
                                           [{ logins: ['not_tested'],
                                              start_date: DateTime.now,
                                              partitions: ['not_tested'] }])
      class << service
        def open_connection; end
        def close_connection; end

        def run_on_cluster(_command)
          [0,
          "20|00:00:00|2025-09-10T15:49:33|2025-09-10T15:49:33|compute
           7|2-02:00:00|2025-09-10T15:49:33|2025-09-10T15:49:33|compute
           3|01:01:04|2025-12-02T20:04:16|2025-12-02T20:04:20|compute",
          '']
        end
      end
      result = service.run.first
      node_hours = 7 *(2* 24 + 2) + 3 * (1 + 1.0/60 + 4.0/3600)
      expect(result[0]).to eq node_hours.to_f
    end

    it 'raises exception if :logins key is not given' do
      service = NodeHourCounterService.new(Core::Cluster.first,
                                           [{ start_date: DateTime.now,
                                              partitions: ['not_tested'] }])
      class << service
        def open_connection; end
        def close_connection; end

        def run_on_cluster(_command)
          [0,
          "20|00:00:00|2025-09-10T15:49:33|2025-09-10T15:49:33|compute
           7|2-02:00:00|2025-09-10T15:49:33|2025-09-10T15:49:33|compute
           3|01:01:04|2025-12-02T20:04:16|2025-12-02T20:04:20|compute",
          '']
        end
      end
      expect { service.run }.to raise_error(ArgumentError)
    end
  end
end
