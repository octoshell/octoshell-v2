# == Schema Information
#
# Table name: comments_comments
#
#  id              :integer          not null, primary key
#  attachable_type :string           not null
#  text            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachable_id   :integer          not null
#  context_id      :integer
#  user_id         :integer          not null
#
# Indexes
#
#  index_comments_comments_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_comments_comments_on_context_id                         (context_id)
#  index_comments_comments_on_user_id                            (user_id)
#

module Comments
  class Comment < ApplicationRecord
    include Attachable
    DEFAUlT_PER = 10
    validates :text, presence: true

    def self.all_records_to_json_view(hash)
      hash[:per] ||= DEFAUlT_PER
      hash[:includes] = {user: %i[groups profile]}
      relation, pages, corrected_page = pag_all_records(hash)
      [relation.to_a.map { |c| c.to_full_json_with_preload hash[:user_id] }, pages, corrected_page]
    end

    def self.to_json_view(hash)
      hash[:per] ||= DEFAUlT_PER
      hash[:includes] = {user: %i[groups profile]}
      relation, pages, corrected_page = pag_records(hash)
      [relation.to_a.map { |c| c.to_full_json_with_preload hash[:user_id] }, pages, corrected_page]
    end

    def to_json_with_preload(user_id)
      attributes = self.attributes.slice('text', 'created_at', 'updated_at', 'id','context_id')
      profile_attributes = user.profile.attributes.slice('first_name', 'last_name', 'middle_name')
      {
        can_update: can_update?(user_id),
        user_groups: groups_names,
        email: user.email,
        context_name: context.try(:name)
      }.merge(attributes)
        .merge(profile_attributes)
    end

    def to_full_json_with_preload(user_id)
      to_json_with_preload(user_id).merge(attachable_to_json)
    end

    def groups_names
      user.groups.map(&:name)
    end
  end
end
