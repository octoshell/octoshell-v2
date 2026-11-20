module CloudComputing
  require 'main_spec_helper'
  describe Access do
    before(:each) do
      CloudComputing::SupportMethods.seed
      @project = create(:project)
      @project2 = create(:project)

      @template = CloudComputing::TemplateKind.virtual_machine_cloud_class.templates.first
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
                                            allowed_by: create(:admin))
        access.copy_from_request(@request)
        access.save!
        access_resource_ids = access.items
                                    .map(&:resource_items)
                                    .flatten.map(&:resource_id)

        request_resource_ids = @request.items
                                       .map(&:resource_items)
                                       .flatten.map(&:resource_id)

        expect(access_resource_ids.sort).to eq request_resource_ids.sort

      end
    end

    describe '#approve!' do
      it 'approves access' do
        allow(@access).to receive(:instantiate_vm)
        @access.approve!
        expect(@access).to be_approved
      end
    end


  end
end
