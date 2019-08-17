  module AccessValidator
    extend ActiveSupport::Concern
    included do
      validates :created_by, :who, :who_id, :status, :to, presence: true
      validates_uniqueness_of :who_id, scope: [:to_type, :to_id, :who_type]
      validate do
        if to.is_a?(Pack::Version) && to.deleted && status != 'deleted'
          errors.add(:status, :version_deleted)
        end
        if new_end_lic_forever && new_end_lic
          errors.add(:new_end_lic, :incorrect_forever)
        end
      end
      validates :to_type, inclusion: { in: [Pack::Package, Pack::Version].map(&:to_s) }
      validates :to, presence: true
      validate do
        next unless to

        if to.is_a?(Pack::Version) && to.package.accesses_to_package
          errors.add(:to_id, :accesses_to_package)
        elsif to.is_a?(Pack::Package) && !to.accesses_to_package
          errors.add(:to_id, :accesses_to_package)
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
