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
      it 'instantiates vm' do
        results = OpennebulaTask.instantiate_vm(@access.positions.first.id)
        puts results.inspect
      end
    end

    describe '::ssh_public_keys' do
      it 'gets all keys associated with project of @access' do
        results = OpennebulaTask.ssh_public_keys(@access.positions.first)
        expect(results).to match_array @ssh_keys
      end
    end
  end
end
