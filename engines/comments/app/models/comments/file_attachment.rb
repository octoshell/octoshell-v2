# == Schema Information
#
# Table name: comments_file_attachments
#
#  id              :integer          not null, primary key
#  attachable_type :string           not null
#  description     :text
#  file            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachable_id   :integer          not null
#  context_id      :integer
#  user_id         :integer          not null
#
# Indexes
#
#  attach_index                                   (attachable_id,attachable_type)
#  index_comments_file_attachments_on_context_id  (context_id)
#  index_comments_file_attachments_on_user_id     (user_id)
#

module Comments
  class FileAttachment < ActiveRecord::Base

    has_paper_trail

    mount_uploader :file, FileUploader
    include Attachable
    DEFAUlT_PER = 10
    validates :description,:file, presence: true

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

    def store_readable_dir
      "/comments/secured_uploads/#{id}/#{file_identifier}"
    end

    def to_json_with_preload(user_id)
      attributes = self.attributes.slice('description', 'created_at', 'updated_at', 'id','context_id')
      attributes['file_url'] = store_readable_dir
      attributes['file_name'] = file_identifier
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
