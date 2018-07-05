# Связь пользователя и языка
class LangPref < ActiveRecord::Base
  belongs_to :user
  validates :language, inclusion: { in: %w(ru en) }
end
