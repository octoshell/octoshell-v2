# == Schema Information
#
# Table name: core_notices
#
#  id              :integer          not null, primary key
#  active          :integer
#  category        :integer
#  count           :integer
#  kind            :string
#  linkable_type   :string
#  message         :text
#  show_from       :datetime
#  show_till       :datetime
#  sourceable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  linkable_id     :integer
#  sourceable_id   :integer
#
# Indexes
#
#  index_core_notices_on_linkable_type_and_linkable_id      (linkable_type,linkable_id)
#  index_core_notices_on_sourceable_type_and_sourceable_id  (sourceable_type,sourceable_id)
#

module Core
  class Notice < ApplicationRecord
    belongs_to :sourceable, polymorphic: true # user or object which should be noticed
    belongs_to :linkable, polymorphic: true   # extra data
    has_many :notice_show_options

    # message:  text    = notice text
    # count:    integer = notices count if applicable
    # category: integer = 0 for wide notices, >0 for per-user notices, other - undefined
    #                     1 = simple per-user notification, 2+ = call handler...
    # kind:     string  = for handler selection
    # show_from: date   = when start to show (nil=now)
    # show_till: date   = when stop to show  (nil=forever)
    # active:   integer = 1(or nil) = is active now (for use in handler only)
    
    def visible?
      opt = self.notice_show_options.take
      ! opt&.hidden
    end

    def self.register_kind k, &block
      @notice_handlers ||= {}
      @notice_handlers[k] = block
    end

    def self.handle notice, user, params, request
      return nil if ! @notice_handlers

      handler = @notice_handlers[notice.kind]
      # nil / [:flash_type, message]
      handler.nil? ? nil : handler.call(notice, user, params, request)
    end

    def source_name
      sourceable.nil? ? '----' :
      sourceable.respond_to?(:full_name) ?
        sourceable.full_name :
        sourceable.respond_to?(:title_ru) ?
          sourceable.title_ru : sourceable.name_ru
    end

    # 
    def self.register_def_per_user_handler
      Core::Notice.register_kind nil do |notice, user, params, request|
        #logger.warn "-> #{notice.id}/#{notice.kind}/#{notice.category}"
        [
          :info,
          "#{notice.message} #{notice.add_close(request)}".html_safe
        ]
      end 
    end

    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def add_close request
      #FIXME!!!! [:admin, :core, self] does not work :(((((
      link = link_to '<i class="fas fa-bell-slash close"></i>'.html_safe, "/core/admin/notices/#{id}/hide?retpath=#{request.fullpath}", data:{retpath: request.fullpath}
      link
    end

    def self.show_notices current_user, params, request
      # per-user: show only if sourceable is current user
      data = []
      Core::Notice.where('category > 0').where(sourceable: current_user, active: true)
        .includes(:notice_show_options)
        .each do |note|
        
        user_option = note.notice_show_options.where(user: current_user).take
        #logger.warn "+++++++++++++++++ #{user_option.inspect}"
        next if user_option && user_option.hidden

        #logger.warn "--->>> #{current_user.id} <<<---"# #{data.inspect}"
        data << conditional_show_notice(note, current_user, params, request)
      end

      # others: show for all (if handler returns not nil)
      Core::Notice.where('category < 1').where(active: true)
        .includes(:notice_show_options)
        .each do |note|

        user_option = note.notice_show_options.where(user: current_user).take
        #logger.warn "================== #{user_option.inspect}"
        next if user_option && user_option.hidden

        data << conditional_show_notice(note, current_user, params, request)
      end
      data.reject{|x| x.nil?}
    end

    def self.conditional_show_notice note, current_user, params, request
      logger.warn "------------------- #{note.inspect}"
      n = Time.current
      return if note.show_from && (note.show_from > n)
      return if note.show_till && (note.show_till < n)
      Core::Notice.handle(note, current_user, params, request)
    end

  end
end
