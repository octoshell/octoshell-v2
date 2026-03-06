module Core
  require 'main_spec_helper'
  describe ResourceUser do
    describe 'validations' do
      let(:access) { create(:core_access) }
      let(:project) { access.project }
      let(:member) { create(:member, project: project) }
      let(:other_member) { create(:member) } # belongs to another project

      it 'requires either email or member' do
        resource_user = build(:core_resource_user, access: access, email: nil, member: nil)
        expect(resource_user).not_to be_valid
        expect(resource_user.errors[:base]).to include('Either email or member must be present')
      end

      it 'is valid with email only' do
        resource_user = build(:core_resource_user, access: access, email: 'test@example.com', member: nil)
        expect(resource_user).to be_valid
      end

      it 'is valid with member only' do
        resource_user = build(:core_resource_user, access: access, email: nil, member: member)
        expect(resource_user).to be_valid
      end

      it 'validates uniqueness of email per access' do
        create(:core_resource_user, access: access, email: 'duplicate@example.com')
        duplicate = build(:core_resource_user, access: access, email: 'duplicate@example.com')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:email]).to include('has already been taken')
      end

      it 'validates uniqueness of member per access' do
        create(:core_resource_user, access: access, member: member)
        duplicate = build(:core_resource_user, access: access, member: member)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:member]).to include('has already been taken')
      end

      it 'allows same email across different accesses' do
        other_access = create(:core_access)
        create(:core_resource_user, access: access, email: 'same@example.com')
        resource_user = build(:core_resource_user, access: other_access, email: 'same@example.com')
        expect(resource_user).to be_valid
      end

      it 'requires member to belong to the same project as access' do
        resource_user = build(:core_resource_user, access: access, member: other_member)
        expect(resource_user).not_to be_valid
        expect(resource_user.errors[:member]).to include('must belong to project')
      end
    end

    describe '#user_or_plain_email' do
      let(:access) { create(:core_access) }
      let(:member) { create(:member, project: access.project) }

      it 'returns member user email when member present' do
        resource_user = create(:core_resource_user, access: access, member: member)
        expect(resource_user.user_or_plain_email).to eq(member.user.email)
      end

      it 'returns email when member absent' do
        resource_user = create(:core_resource_user, access: access, email: 'external@example.com')
        expect(resource_user.user_or_plain_email).to eq('external@example.com')
      end

      it 'returns nil when both member and email absent (should not happen due to validation)' do
        resource_user = build(:core_resource_user, access: access, email: nil, member: nil)
        expect(resource_user.user_or_plain_email).to be_nil
      end
    end

    describe 'association' do
      it 'belongs to member' do
        resource_user = create(:core_resource_user)
        expect(resource_user.member).to be_a(Core::Member)
      end

      it 'belongs to access' do
        resource_user = create(:core_resource_user)
        expect(resource_user.access).to be_a(Core::Access)
      end
    end
  end
end
