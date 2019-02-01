# == Schema Information
#
# Table name: hardware_states_links
#
#  id         :integer          not null, primary key
#  from_id    :integer
#  to_id      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Hardware
  class StatesLink < ActiveRecord::Base
    belongs_to :from, class_name: "State"
    belongs_to :to, class_name: "State"
    validate do
      errors.add(:from, :invalid) if from.kind != to.kind
    end
  end
end
