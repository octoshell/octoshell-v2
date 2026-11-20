module CloudComputing
  require 'main_spec_helper'
  describe OpennebulaTask do
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
      CloudComputing::SupportMethods.add_positions(@access, @template)

    end

    describe '::hash_from_item' do
      it 'forms hash from item' do
        item = @access.items.first
        hash = OpennebulaTask.hash_from_item({}, item)
        expect(hash['CPU']).to eq(2.0)
        expect(hash['VCPU']).to eq(2)
        expect(hash['MEMORY']).to eq(2048)
      end
    end

    describe '::instantiate_vm' do
      it 'instantiates vm' do
        item = @access.items.create!(template: @template)
        allow(OpennebulaClient).to receive(:template_info).and_return(
          [true, '<VMTEMPLATE><TEMPLATE><CONTEXT><ETH0_IP>1.2.3.4</ETH0_IP></CONTEXT></TEMPLATE></VMTEMPLATE>']
        )
        allow(OpennebulaClient).to receive(:instantiate_vm).and_return([true, '123'])

        results = OpennebulaTask.instantiate_vm(item, 'ssh-rsa test')

        expect(item.reload.virtual_machine.identity).to eq(123)
      end
    end

    describe '::ssh_public_keys' do
      it 'gets all keys associated with project of @access' do
        results = OpennebulaTask.ssh_public_keys(@access)
        expect(results).to match_array @ssh_keys
      end
    end
  end
end
