module Core
  class Notice < ActiveRecord::Base
    belongs_to :sourceable, polymorphic: true
    belongs_to :linkable, polymorphic: true

    # message: text
    # count: integer
    # type: integer
  end
end
