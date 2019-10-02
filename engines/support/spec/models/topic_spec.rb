require 'main_spec_helper'
module Support
  RSpec.describe Topic do

    let(:topic) { create(:topic) }
    let(:superadmins) { Group.find_by_name!('superadmins') }

    before(:each) do
      topic.permissions.create!(group: superadmins)
    end

    it 'shows permissions' do
      expect(topic.permissions.to_a.first).to(
        have_attributes(subject_class: Topic.to_s, subject_id: topic.id,
                        action: 'answer', available: true))
    end

    # it 'shows resposible_groups when there is the same id' do
    #   expect(topic.resposible_groups.to_a.map(&:groups)).to eq [superadmins]
    # end
  end
end
