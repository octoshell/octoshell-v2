User.class_eval do
  has_many :created_pack_accesses, class_name: "Pack::Access",
                                   foreign_key: :created_by_id,
                                   dependent: :destroy
  has_many :user_pack_accesses, ->{ where(who_type: 'User') },
                                class_name: "Pack::Access",
                                foreign_key: :who_id, dependent: :destroy
end
