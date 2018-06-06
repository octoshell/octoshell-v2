module AccessValidator
  extend ActiveSupport::Concern
  included do
    validates :version, :created_by, :who, :status, presence: true
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
    end_lic && new_end_lic && %w[expired allowed].include?(status)
  end

  def new_end_lic_correct
    if end_lic && new_end_lic && (end_lic >= new_end_lic)
      errors.add(:new_end_lic, :incorect_date)
    elsif new_end_lic || new_end_lic_forever
      errors.add(:new_end_lic, :incorect_date)
    end
    errors.add(:new_end_lic, :status_only) if new_end_lic_incorrect_status?
    if new_end_lic && !end_lic
      errors.add(:new_end_lic, 'must be blank')
    end
  end
end
