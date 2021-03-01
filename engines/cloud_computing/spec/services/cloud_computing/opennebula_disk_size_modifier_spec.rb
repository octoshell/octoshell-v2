module CloudComputing
  require 'main_spec_helper'
  describe OpennebulaDiskSizeModifier do
    before(:each) do
      CloudComputing::SupportMethods.seed
      @project = create(:project)
      @ssh_keys = []
      2.times do
        user = create(:user)
        @project.members.create!(user: user, project_access_state: 'allowed')
        key = SSHKey.generate(comment: user.email)
        @ssh_keys << key.ssh_public_key
        Core::Credential.create!(user: user, name: 'example key',
                                 public_key: key.ssh_public_key)

      end

      user_without_active_key = create(:user)
      key = SSHKey.generate(comment: user_without_active_key.email)
      Core::Credential.create!(user: user_without_active_key, name: 'example key',
                               state: 'deactivated',
                               public_key: key.ssh_public_key)
      @project.users << user_without_active_key
      @project.users << create(:user)

      @template = CloudComputing::TemplateKind.virtual_machine_cloud_class.templates.first
      @access = CloudComputing::Access.create!(for: @project,
                                               user: @project.owner,
                                               allowed_by: create(:admin))
      @vm_data = CloudComputing::SupportMethods.example_vm_hash
    end

    it 'does not change vm' do
      CloudComputing::SupportMethods.create_vm_with_identities(@access,
        @template, 'DISK=>SIZE' => 3)
      vm = VirtualMachine.last
      r_m = OpennebulaDiskSizeModifier.new(vm, @vm_data)
      expect(r_m.send(:to_change?)).to eq false
    end

    it 'changes cpu and memory' do
      CloudComputing::SupportMethods.create_vm_with_identities(@access,
        @template, 'DISK=>SIZE' => 4)
      vm = VirtualMachine.last
      r_m = OpennebulaDiskSizeModifier.new(vm, @vm_data)
      expect(r_m.send(:to_change?)).to eq true
    end

    it 'changes cpu and memory with request' do
      CloudComputing::SupportMethods.create_vm_with_identities(@access,
        @template, 'DISK=>SIZE' => 3)

      vm = VirtualMachine.last

      item = @access.items.create!(template: vm.item.template, item_in_access: vm.item)

      resource = @template.resources.joins(:resource_kind)
                         .where(cloud_computing_resource_kinds:{
                           identity: 'DISK=>SIZE'
        }).first

      item.resource_items.create!(resource: resource, value: '4')

      r_m = OpennebulaDiskSizeModifier.new(vm, @vm_data)
      r_m.instance_variable_set('@results', [true, 'data'])
      expect(r_m.send(:to_change?)).to eq true
      expect { r_m.send(:remove_access_resource_item) }.to change { ResourceItem.count }.by(-1)

    end




  end
end
