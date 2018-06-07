# module Pack
#   class AdminAccessUpdater
#     ACCESS_ATTRIBUTES = Access.new.attributes.keys
# 		include ActiveModel::Validations
#     include AccessValidator
#     attr_accessor :access, :admin, :forever, :delete_request
#     attr_accessor(*ACCESS_ATTRIBUTES)
#     delegate :permitted_states_with_own, :who, :created_by, to: :access
#     delegate :version, to: :access
#     validate do
#       unless permitted_states_with_own.include? status
#         errors.add(:status, :incorrect_status)
#       end
#     end
#
#     def initialize(access, admin, hash)
# 			@access = access
#       @admin = admin
# 			# puts Access.new.attributes.keys
# 			# puts @access.attributes
# 			# puts hash
# 			# puts (@access.attributes.except('who_user','who_group','who_project').merge hash.except('who','created_by'))
#
#       (@access.attributes.except(*%w[who_user who_group who_project]).merge hash.except(*%w[who created_by])).each do |key, value|
#         send("#{key}=", value)
#       end
#     end
#
#
#     def requested_update
#       access.assign_attributes(status: status, end_lic: end_lic)
#       return unless status == 'allowed'
#       access.allowed_by = admin
#     end
#
#     def approve_access
#       if new_end_lic_forever
#         self.end_lic = nil
#       else
#         self.end_lic = new_end_lic
#       end
#       delete_request_info
#       assign_attributes %i[new_end_lic new_end_lic_forever end_lic]
#     end
#
#     def assign_attributes(array)
#       array.each do |a|
#         access.send("#{a}=", a)
#       end
#     end
#
#
#     def delete_request_info
#       self.new_end_lic = nil
#       self.new_end_lic_forever = false
#     end
#
#     def allowed_expired_update
#       if status == 'make_longer'
#         approve_access
#       elsif status == 'deny_longer'
#         delete_request_info
#         access.new_end_lic = nil
#         access.new_end_lic_forever = nil
#         assign_attributes %i[new_end_lic new_end_lic_forever]
#       elsif %w[allowed expired].include?(status)
#         delete_request_info if delete_request
#         assign_attributes %i[end_lic new_end_lic new_end_lic_forever]
#       end
#     end
#
#     def save!
#       access.save!
#     end
#
#     def proccess
#       unless %w[expired allowed].include?(status)
#         self.new_end_lic_forever = false
#         self.new_end_lic = nil
#       end
#       self.end_lic = nil if forever
#       self.new_end_lic = nil if new_end_lic_forever
#       case access.status
#       when 'requested'
#         requested_update
#       when 'allowed', 'expired'
#         allowed_expired_update
#       end
#       save! if valid?
#     end
#
#     def self.update(access, admin, hash)
#       new(access, admin, hash).proccess
#     end
#   end
# end
