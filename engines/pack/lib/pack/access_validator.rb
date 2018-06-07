module AccessValidator
  extend ActiveSupport::Concern
  included do
    validates :version, :created_by, :who, :status, presence: true
    validates_uniqueness_of :who_id, scope: [:version_id,:who_type]

    validate do
      if version.deleted && status != 'deleted'
        errors.add(:status, :version_deleted)
      end
      if new_end_lic_forever && new_end_lic
        errors.add(:new_end_lic, :incorrect)
      end
    end
    validate :new_end_lic_correct
  end

  def new_end_lic_incorrect_status?
    new_end_lic && !%w[expired allowed].include?(status)
  end

  def new_end_lic_forever_incorrect_status?
    new_end_lic_forever && !%w[expired allowed].include?(status)
  end

  def new_end_lic_correct
    if user_edit && end_lic && new_end_lic && (end_lic >= new_end_lic)
      errors.add(:new_end_lic, :incorect_date)
    end

    if new_end_lic && new_end_lic_forever
      errors.add(:new_end_lic_forever, :incorrect_date)
    end

    errors.add(:new_end_lic, :status_only) if new_end_lic_incorrect_status?
    errors.add(:new_end_lic_forever, :status_only) if new_end_lic_forever_incorrect_status?

    if new_end_lic && !end_lic
      errors.add(:new_end_lic, 'must be blank')
    end
  end
end
