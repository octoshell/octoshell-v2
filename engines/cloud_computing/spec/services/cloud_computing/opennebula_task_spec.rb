module CloudComputing
  require 'main_spec_helper'
  describe OpennebulaTask do
    before(:each) do
      CloudComputing::SupportMethods.seed
      @project = create(:project)
      @template = CloudComputing::ItemKind.virtual_machine.first.items.first
      @access = CloudComputing::Access.create!(for: @project,
                                               user: @project.owner,
                                               allowed_by: create(:admin))
      CloudComputing::SupportMethods.add_positions(@access, @template)
    end

    describe '::hash_from_position' do
      it 'forms hash from position' do
        hash = OpennebulaTask.hash_from_position({}, @access.positions.first)
        puts hash.inspect
      end
    end

    describe '::instantiate_vm' do
      it 'forms hash from position' do
        results = OpennebulaTask.instantiate_vm(@template.identity,
                                                @access.positions.first)
        puts results.inspect
      end
    end


  end
end
