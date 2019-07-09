# == Schema Information
#
# Table name: core_notices
#
#  id              :integer          not null, primary key
#  category        :integer
#  count           :integer
#  linkable_type   :string
#  message         :text
#  sourceable_type :string
#  type            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  linkable_id     :integer
#  sourceable_id   :integer
#
# Indexes
#
#  index_core_notices_on_linkable_type_and_linkable_id      (linkable_type,linkable_id)
#  index_core_notices_on_sourceable_type_and_sourceable_id  (sourceable_type,sourceable_id)
#

module Core
  class Notice < ActiveRecord::Base

    has_paper_trail

    belongs_to :sourceable, polymorphic: true
    belongs_to :linkable, polymorphic: true

    # message: text
    # count: integer
    # type: integer
  end
end
