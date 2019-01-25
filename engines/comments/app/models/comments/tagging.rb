# == Schema Information
#
# Table name: comments_taggings
#
#  id              :integer          not null, primary key
#  tag_id          :integer
#  attachable_id   :integer          not null
#  attachable_type :string           not null
#  user_id         :integer
#  context_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

module Comments
  class Tagging < ActiveRecord::Base
    DEFAUlT_PER = 20
    include Attachable
    validates :tag, presence: true
    validates_uniqueness_of :tag_id, scope: [:attachable_id, :attachable_type,:context_id]
    belongs_to :tag, inverse_of: :taggings
    after_destroy do
      tag.destroy if tag.taggings.empty?
    end

    def self.allowed(user_id)
      Tagging.join_user_groups(user_id).includes(:tag).order("created_at DESC")
              .group(:tag_id).select("MAX(comments_taggings.created_at) AS created_at, MAX(comments_taggings.tag_id) as tag_id")
    end

    def self.to_json_view(hash)
      hash[:per] ||= DEFAUlT_PER
      hash[:includes] = [:tag, { user: %i[groups profile] }]
      relation, pages, corrected_page = pag_records(hash)
      [relation.to_a.map { |c| c.to_json_with_preload hash[:user_id] }, pages, corrected_page]
    end


    def to_json_with_preload(user_id)
      profile_attributes = user.profile.attributes.slice('first_name', 'last_name', 'middle_name')
      { name: tag.name,
        can_update: can_update?(user_id), id: id,
        user_groups: groups_names,
        email: user.email,
        context_name: context.try(:name) }.merge(profile_attributes)
    end

    def groups_names
      user.groups.map(&:name)
    end


    def self.attach_tags!(params)
      transaction do
        names = params['name']
        names.split(';').each do |elem|
          next if elem =~ /^\s*$/
          name = elem.gsub(/\s{2,}/, ' ').gsub(/^\s+/, '').gsub(/\s+$/, '')
          tag = Tag.find_or_create_by!(name: name)
          create_hash = params.except("name").merge(tag: tag)
          create_hash['context_id'] = nil if create_hash['context_id'] == ' '
          create!(create_hash) unless where(create_hash.except(:user)).exists?
        end
      end
    end
  end
end
