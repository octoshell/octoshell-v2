  module AdminAccessUpdate
    extend ActiveSupport::Concern
    included do
      attr_accessor :admin
    end

    def admin_update(admin, hash)
      @admin = admin
      hash = hash.to_h.symbolize_keys
      # hash.symbolize_keys!
      raise "incorrect action" if actions.exclude?(hash[:status])
      raise "LOCK VERSION UPDATED" if lock_version_updated?(hash[:lock_version])
      @status_from_params = hash[:status]
      case status
      when 'requested', 'denied', 'deleted'
        requested_update hash
      when 'allowed', 'expired'
        allowed_expired_update hash
      end
      save!
    end

    def assign_end_lic(forever: 'false', end_lic: nil, **)
      if forever == 'true'
        self.end_lic = nil
      elsif end_lic
        self.end_lic = end_lic
      end
    end


    def requested_update(hash)
      self.status = hash[:status]
      assign_end_lic(hash)
      return if status != 'allowed' || allowed_by
      self.allowed_by = admin
    end

    def approve_access
      if new_end_lic_forever
        self.end_lic = nil
      elsif new_end_lic
        self.end_lic = new_end_lic
      else
        raise "NO new_end_lic_forever or end_lic provided"
      end
      delete_request_info
    end

    def delete_request_info
      self.new_end_lic = nil
      self.new_end_lic_forever = false
    end

    def allowed_expired_update(hash)
      if hash[:status] == 'make_longer'
        approve_access
      elsif hash[:status] == 'deny_longer'
        delete_request_info
      elsif %w[allowed expired].include?(hash[:status])
        delete_request_info if hash[:delete_request] == 'true'
        assign_end_lic(hash)
      else
        self.status =  hash[:status]
      end
    end
  end
