module Pack
  class AdminAccessUpdater < OpenStruct
    include ActiveModel::Validations
    include AccessValidator
    attr_reader :access, :admin
    delegate :permitted_states_with_own, :who, :created_by, to: :access
    delegate :version, to: :access
    validate do
      unless permitted_states_with_own.include? status
        errors.add(:status, :incorrect_status)
      end
    end

    def initialize(access, admin, hash)
      @access = access
      @admin = admin
      super @access.attributes.merge hash.except(:who, :created_by)
    end


    def requested_update
      access.assign_attributes(status: status, end_lic: end_lic)
      return unless status == 'allowed'
      access.allowed_by = admin
    end

    def save!
      access.save!
    end

    def proccess
      unless ["expired","allowed"].include?(status)
        self.new_end_lic_forever = false
        self.new_end_lic = nil
      end
      self.end_lic = nil if forever
      self.new_end_lic = nil if new_end_lic_forever
      case access.status
      when 'requested'
        requested_update
      end
      if valid?
        save!
        true
      else
        false
      end
    end

    def self.update(access, admin, hash)
      new(access, admin, hash).proccess
    end
  end
end
