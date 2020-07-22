# == Schema Information
#
# Table name: core_notice_show_options
#
#  id             :bigint(8)        not null, primary key
#  answer         :string
#  hidden         :boolean          default(FALSE), not null
#  resolved       :boolean          default(FALSE), not null
#  core_notice_id :bigint(8)
#  core_user_id   :bigint(8)
#
# Indexes
#
#  index_core_notice_show_options_on_core_notice_id  (core_notice_id)
#  index_core_notice_show_options_on_core_user_id    (core_user_id)
#

module Core
  #
  # Disable notice show by user and possibly other useful things
  #
  # @author [serg]
  #
  class NoticeShowOption < ApplicationRecord
    belongs_to :user
    belongs_to :notice

    # hidden:   boolean = is hidden by user
    # resolved: boolean = optional (mark as resolved)
    # answer:   string  = optional (user answer)

    def self.versions_enabled
      true
    end
  end
end
