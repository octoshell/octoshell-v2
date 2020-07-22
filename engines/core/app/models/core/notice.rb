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
    belongs_to :sourceable, polymorphic: true # user or object to be noticed
    belongs_to :linkable, polymorphic: true   # extra data
    has_many :notice_show_options

    SITE_WIDE = 0
    PER_USER = 1
    OTHER = -1
    # message:  text    = notice text
    # count:    integer = notices count if applicable
    # category: integer = 0 for wide notices,
    #                     >0 for per-user notices,
    #                     1 = simple per-user notification, 2+ = call handler...
    #                     other - undefined
    # kind:     string  = for handler selection
    # show_from: date   = when start to show (nil=now)
    # show_till: date   = when stop to show  (nil=forever)
    # active:   integer = 1(or nil) = is active now (for use in handler only)

    def visible?(user = nil)
      # user ||= current_user
      opt = notice_show_options.where(user: user).take
      !opt&.hidden
    end

    def self.register_kind(k, &block)
      @notice_handlers ||= {}
      @notice_handlers[k] = block
      # logger.warn "::: @handlers= #{@notice_handlers.inspect}"
    end

    def self.handle(notice, user, params, request)
      return nil unless @notice_handlers

      handler = @notice_handlers[notice.kind.to_s]
      handler.nil? ? nil : handler.call(notice, user, params, request)
    end

    def source_name
      if sourceable.nil?
        '----'
      elsif sourceable.respond_to?(:full_name)
        sourceable.full_name
      elsif sourceable.respond_to?(:title_ru)
        sourceable.title_ru
      else
        sourceable.name_ru
      end
    end

    def self.register_def_nil_kind_handler
      Core::Notice.register_kind nil.to_s do |notice, user, _, request|
        if notice.visible? user
          [
            :info,
            "#{notice.message} #{notice.add_close(request)}".html_safe
          ]
        else
          nil
        end
      end
    end

    # def self.register_def_worldwide_handler
    #   Core::Notice.register_kind nil.to_s do |notice, user, params, request|
    #     # logger.warn "-> #{notice.id}/#{notice.kind}/#{notice.category}"
    #     [
    #       :info,
    #       "#{notice.message} #{notice.add_close(request)}".html_safe
    #     ]
    #   end
    # end

    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def add_close(request)
      # FIXME!!!! [:admin, :core, self] does not work :(((((
      link = link_to(
        '<i class="fas fa-bell-slash close"></i>'.html_safe,
        "/core/admin/notices/#{id}/hide?retpath=#{request.fullpath}",
        data: { retpath: request.fullpath }
      )
      link
    end

    def category_str
      if category.zero?
        I18n.t('.core.admin.notices.site-wide')
      elsif category == 1
        I18n.t('.core.admin.notices.per-user')
      else
        I18n.t('.core.admin.notices.other')
      end
    end

    def self.show_notices(current_user, params, request)
      # per-user: show only if sourceable is current user
      data = []
      # ----------------- PER USER -----------------------
      Core::Notice
        .where('category > 0')
        .where(sourceable: current_user, active: 1)
        .includes(:notice_show_options)
        .each do |note|

        user_option = note.notice_show_options.where(user: current_user).take
        next if user_option&.hidden

        data << conditional_show_notice(note, current_user, params, request)
      end

      # others: show for all (if handler returns not nil)
      # ----------------- SITE WIDE (0) & OTHERS -----------------------
      Core::Notice
        .where('category < 1')
        .where(active: 1)
        .includes(:notice_show_options)
        .each do |note|

        user_option = note.notice_show_options.where(user: current_user).take
        next if user_option&.hidden

        data << conditional_show_notice(note, current_user, params, request)
      end
      data.reject(&:nil?)
    end

    def self.conditional_show_notice(note, current_user, params, request)
      n = Time.current
      return nil if note.show_from && (note.show_from > n)
      return nil if note.show_till && (note.show_till < n)
      ret = Core::Notice.handle(note, current_user, params, request)
      ret
    end

    def self.get_count_for_user(user)
      peruser = Core::Notice
        .where('category > 0')
        .where(sourceable: user, active: 1)
        .count
      sitewide = Core::Notice
        .where('category < 1')
        .where(active: 1).count
      peruser + sitewide
    end
  end
end
