PaperTrail::Version.class_eval do
  belongs_to :user, foreign_key: :whodunnit
end
