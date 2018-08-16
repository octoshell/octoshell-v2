module Pack
  class VersionOption < ActiveRecord::Base
    belongs_to :version, inverse_of: :version_options

    translates :name, :value
    validates :version, presence: true
    validates_translated :name, :value, presence: true
    validates_translated :name, :value, presence: true
    validates_uniqueness_of :name_ru, scope: :version_id
    validates_uniqueness_of :name_en, scope: :version_id
    attr_accessor :stale_edit
    validate :stale_check

    def stale_check
      return unless stale_edit
      mark_for_destruction
      errors.add(:deleted_record,I18n.t("stale_error_nested"))
    end

  end
end
