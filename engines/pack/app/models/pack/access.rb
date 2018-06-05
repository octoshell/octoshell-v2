module Pack
  class Access < ActiveRecord::Base

    def self.expired_accesses
      Access.transaction do
        where("end_lic < ? and status='allowed'", Date.today).each{ |ac| ac.update!(status: 'expired') }
      end
    end
    include AASM
    american_date_proccess
    validates :version, :created_by,:who,:status,presence: true
    validates_uniqueness_of :who_id,:scope => [:version_id,:who_type]
    attr_accessor :user_edit
    aasm :column => :status  do
      state :requested,:initial => true
      state :allowed
      state :denied
      state :expired
      state :deleted
      event :to_expired do
        transitions from:  :allowed, to: :expired, guard: :check_expired?
      end
      event :to_allowed do
        transitions from:  :expired, to: :allowed,
                    guard: :check_allowed?, success: :allowed_callback
      end
      event :allow do
        transitions from:  %i[requested denied],
                    to: :allowed, guard: :check_allowed?
      end
      # event :expire do
      #   transitions :from =>  [:denied], :to => :expired, guard: :check_expired?
      # end
      event :deny do
        transitions from:  %i[requested expired allowed],
                    to: :denied
      end
    end

    def allowed_callback
      if forever
        self.end_lic = self.new_end_lic = nil
      end
    end


    belongs_to :version
    belongs_to :created_by,class_name: '::User',foreign_key: :created_by_id
    belongs_to :allowed_by,class_name: '::User',foreign_key: :allowed_by_id
    belongs_to :who, :polymorphic => true
    has_and_belongs_to_many :tickets, join_table: 'pack_access_tickets', class_name: "Support::Ticket",
                                      foreign_key: "access_id",
                                      association_foreign_key: "ticket_id"

    scope :preload_who, -> { select("pack_accesses.*,u.email as who_user,proj.title as who_project,g.name as who_group").joins(<<-eoruby
         LEFT JOIN core_projects as proj ON (proj.id= "pack_accesses"."who_id" AND pack_accesses.who_type='Core::Project'  )
         LEFT JOIN users as u ON (u.id= "pack_accesses"."who_id" AND pack_accesses.who_type='User'  )
         LEFT JOIN groups as g ON (g.id= "pack_accesses"."who_id" AND pack_accesses.who_type='Group'  )
        eoruby
        )
        }

    after_commit :send_email,if: Proc.new{( who_type == 'User' ||
                                      who_type == 'Core::Project') && !user_edit}
    after_save :create_ticket, if: Proc.new { user_edit && (new_end_lic &&
                                              changes[:new_end_lic] &&
                                              !changes[:new_end_lic][0] ||
                                              status=='requested')}
    before_validation do
      self.new_end_lic = nil unless ["expired","allowed"].include?(status)
      to_expired if may_to_expired?
      to_allowed if may_to_allowed?
    end

    def send_email
      if status != 'requested'
        if previous_changes["status"]
          ::Pack::PackWorker.perform_async(:access_changed, id)
        end
        if previous_changes["new_end_lic"] && ["expired","allowed"].include?(status)
          if previous_changes["end_lic"]
            ::Pack::PackWorker.perform_async(:access_changed, [id,"made_longer"])
          else
            ::Pack::PackWorker.perform_async(:access_changed, [id,"denied_longer"])
          end
        end
      end
    end

    def create_ticket
      subject= if new_end_lic
        I18n.t('tickets_access.subject.new_end_lic',who_name: who_name_with_type,user: created_by.email)
      elsif status == 'requested'
        I18n.t('tickets_access.subject.requested',who_name: who_name_with_type,user: created_by.email)
      end
      Pack.support_access_topic_id ||= Support::Topic.find_by(name: I18n.t('integration.support_theme_name')).id
      tickets.create!(subject: subject, reporter: created_by, message: subject,topic_id: Pack.support_access_topic_id)
    end

    def version_name
      version.name
    end

    def self.user_access(user_id)
        user_access_without_select(user_id)
    end





    def self.joins_projects_groups(user_id)

       if user_id==true
        user_id=1
      end

        select('pack_accesses.*,groups.name as who_name_from_union').joins(
        <<-eoruby
        INNER JOIN "user_groups" ON ( "pack_accesses"."who_id" = "user_groups"."group_id"
        AND "user_groups"."user_id" = #{user_id}   AND "pack_accesses"."who_type" = 'Group' )
        LEFT JOIN "groups" ON ( "user_groups"."group_id" = "groups"."id"  )
        eoruby
        ).union(  select('pack_accesses.*,core_projects.title as who_name_from_union').joins(
        <<-eoruby
        INNER JOIN "core_members" ON ( "pack_accesses"."who_id" = "core_members"."project_id"
        AND "core_members"."user_id" = #{user_id} AND "pack_accesses"."who_type" = 'Core::Project'   )
        LEFT JOIN core_projects ON core_projects.id= core_members.project_id
        eoruby
        )).union  select("pack_accesses.*,'User' as who_name_from_union").where(
         <<-eoruby
         "pack_accesses"."who_type" = 'User' AND "pack_accesses"."who_id" = #{user_id}
         eoruby
         )
    end

    def self.user_access_without_select(user_id)

        if user_id==true
          user_id=1
        end

        joins_projects_groups(user_id).order(:id)

    end

    def actions
      st=(aasm.states(:permitted => true).map(&:to_s) )<<'edit_by_hand'

      if end_lic && new_end_lic
        st + ['make_longer','deny_longer']
      else
        st
      end


    end

    def actions_for_select
      actions.map{ |a| [I18n.t("access_actions.#{a}"),a]  }
    end

    def self.states_list

      aasm.states.map(&:to_s)

    end
    def self.states_list_readable

      aasm.states.map{ |st| [I18n.t( "access_states.#{st}" ),st ]  }

    end
    def self.states_list_for_form


      (aasm.states.map(&:to_s)-["expired"] ).map{ |st| [I18n.t( "access_states.#{st}" ),st ]  }

    end

    def self.ransackable_scopes(auth_object = nil)
      %i[user_access user_access_without_select requests]
    end

    def self.requests
      where("new_end_lic IS NOT NULL OR new_end_lic_forever = 't'")
    end

    def action; end

    def action= arg

      if arg == 'make_longer'

        if !new_end_lic

           @date_err=true
        end

        self.end_lic = new_end_lic
        self.new_end_lic= nil
      elsif arg=='deny_longer'
        self.new_end_lic= nil

      else

        self.status= arg
      end
    end

    def check_expired?
      end_lic && (end_lic < Date.current)
    end

    def check_allowed?
       end_lic && end_lic >= Date.current || !end_lic || forever
    end

    validate do
      if version.deleted && status != 'deleted'
        errors.add(:status, :version_deleted)
      end
      if new_end_lic_forever && new_end_lic
        errors.add(:new_end_lic, :incorrect)
      end
    end

    validate :new_end_lic_correct

    def new_end_lic_uncorrect_status?
      end_lic && new_end_lic && %w[expired allowed].include?(status)
    end

    def new_end_lic_correct
      # if @date_err || end_lic && new_end_lic && ( end_lic >= new_end_lic )
      #   self.errors.add(:new_end_lic,:incorect_date)
      # end

      errors.add(:new_end_lic, :status_only) if new_end_lic_uncorrect_status?
      if new_end_lic && !end_lic
        errors.add(:new_end_lic, 'must be blank')
      end
    end

    def end_lic_readable
      end_lic || Access.human_attribute_name(:forever)
    end
    def status_readable
      I18n.t("access_states.#{status}")
    end

    def lock_version_updated? lock_version
      self.lock_version != lock_version.to_i
    end

    def self.search_access(params, user_id)
      find_params =  case params[:type]
                     when 'user'
                        { who_id: user_id, who_type: 'User' }
                     else
                         { who_id: params[:type], who_type: 'Core::Project' }
                     end
      find_params.merge! params.slice(:version_id)
      # params.slice!(:end_lic,:new_end_lic)
      # params.merge! find_params
      # params.permit!
      # Access.find_by(find_params)   || Access.new(params)
      Access.find_by(find_params)
    end

    def self.new_user_access(access_params, user_id)
      access = search_access(access_params, user_id)
      return { access: access, error: '.created_during_edit' } if access
      access = if access_params[:forever] == 'true'
                Access.new(end_lic: nil)
               else
                Access.new(end_lic: access_params[:end_lic])
               end
      if access_params[:type] == 'user'
        access.assign_attributes(who_id: user_id, who_type: 'User')
      elsif access_params[:type].scan(/\D/).empty?
        access.assign_attributes(who_id: access_params[:type], who_type: 'Core::Project')
      else
        raise ArgumentError, "Invalid params[:type]"
      end
      access.version_id = access_params[:version_id]
      access.created_by_id = user_id
      access
    end

    def self.user_update(access_params, user_id)
      if access_params[:status] == 'new'
        access = new_user_access(access_params, user_id)
      else
        access = search_access(access_params, user_id)
      end

      if access_params[:status] == 'requested' && access_params[:delete] == 'true'
        if !access || access.lock_version_updated?(access_params[:lock_version])
          return { access: access, error: '.updated_during_edit' }
        else
          access.destroy
          return access
        end
      end

      if access_params[:status] == 'allowed'
        if !access || access.lock_version_updated?(access_params[:lock_version])
          return { access: access, error: '.updated_during_edit' }
        else
          if access_params[:new_end_lic_forever] == 'true'
            access.new_end_lic_forever = true
            access.new_end_lic = nil
          else
            access.new_end_lic_forever = false
            access.new_end_lic = access_params[:new_end_lic]
          end
        end
      end
      return access if access.is_a?(Hash)
      access.user_edit = true
      access.save!
      access
    end


    def who_name_with_type



      "#{I18n.t('who_types.'+who_type)} \"#{who_name}\""
    end


    def who_name
      try(:who_name_from_union) ||  try(:who_project) || try(:who_group) || try(:who_user) || who_name_without_preload
    end
    def who_name_without_preload

      case who_type
      when 'User'
        who.email
      when 'Core::Project'
        who.title
      when 'Group'
        who.name
      else
        raise 'unrecognizable who_type'
      end


    end




  end
end
