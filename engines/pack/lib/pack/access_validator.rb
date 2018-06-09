module AccessValidator
  extend ActiveSupport::Concern
  included do
    validates :version, :version_id, :created_by, :who, :who_id, :status, presence: true
    validates_uniqueness_of :who_id, scope: [:version_id,:who_type]
    validate do
      if version && version.deleted && status != 'deleted'
        errors.add(:status, :version_deleted)
      end
      if new_end_lic_forever && new_end_lic
        errors.add(:new_end_lic, :incorrect_forever)
      end
    end
    validate :new_end_lic_correct
    before_validation do
      unless ["expired","allowed"].include?(status)
        self.new_end_lic_forever = false
        self.new_end_lic = nil
      end
      to_expired if may_to_expired?
      to_allowed if may_to_allowed?

      if new_end_lic && !end_lic
        self.new_end_lic = nil
      end

      if new_end_lic_forever && !end_lic
        self.new_end_lic_forever = false
      end
      # self.new_end_lic = nil if new_end_lic && (!end_lic || new_end_lic <= end_lic)
      # self.new_end_lic_forever = false unless end_lic
    end
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

    puts new_end_lic
    puts new_end_lic_forever
    if new_end_lic && new_end_lic_forever
      errors.add(:new_end_lic_forever, :incorrect_date)
    end

    errors.add(:new_end_lic, :status_only) if new_end_lic_incorrect_status?
    errors.add(:new_end_lic_forever, :status_only) if new_end_lic_forever_incorrect_status?

    if new_end_lic && !end_lic
      errors.add(:new_end_lic, 'must be blank')
    end

    if new_end_lic_forever && !end_lic
      errors.add(:new_end_lic_forever, 'must be false')
    end

  end
end
