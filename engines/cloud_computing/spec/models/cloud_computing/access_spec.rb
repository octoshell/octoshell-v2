module CloudComputing
  require 'main_spec_helper'
  describe Access do
    before(:each) do
      CloudComputing::SupportMethods.seed
      @project = create(:project)
      @project2 = create(:project)

      @template = CloudComputing::ItemKind.virtual_machine.first.items.first
      @request = CloudComputing::Request.create!(for: @project, created_by: @project.owner)
      @access = CloudComputing::Access.create!(for: @project2,
        user: @project2.owner, allowed_by: create(:admin))

      CloudComputing::SupportMethods.add_positions(@access, @template)

      CloudComputing::SupportMethods.add_positions(@request, @template)
    end

    describe '#copy_from_request' do
      it 'copies from request' do
        access = CloudComputing::Access.new(for: @project,
                                            user: @project.owner,
                                            allowed_by: create(:admin),
                                            request: @request)
        access.copy_from_request
        access.save!
        access_resource_ids = access.positions
                                    .map(&:resource_positions)
                                    .flatten.map(&:resource_id)

        request_resource_ids = @request.positions
                                       .map(&:resource_positions)
                                       .flatten.map(&:resource_id)

        expect(access_resource_ids.sort).to eq request_resource_ids.sort

      end
    end

    describe '#pend!' do
      it 'pends' do
        @access.pend!
        puts @access.positions&.first&.nebula_identities&.first&.api_logs.inspect
        puts @access.positions.first.api_logs.first.log.inspect

      end
    end


  end
end
